import 'package:flutter/material.dart';
import 'package:peer42/src/core/utils/app_navigator.dart';
import 'package:peer42/src/features/profile/widgets/coalition_widget.dart';
import 'package:peer42/src/features/profile/widgets/profile_header.dart';
import 'package:peer42/src/features/profile/widgets/profile_info_section.dart';
import 'package:peer42/src/features/profile/widgets/profile_tab_bar.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/coalition_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  CoalitionModel? _coalition;
  List<ProjectModel> _projects = [];
  List<SkillModel> _skills = []; // ← Doğru tip
  List<AchievementModel> _achievements = []; // ← Doğru tip
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedTab = 0;

  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  final List<String> _tabs = ['Info', 'Projects', 'Skills', 'Achievements'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic> && args['user'] != null) {
      final user = args['user'] as UserModel;
      setState(() {
        _user = user;
      });
      _contentController.forward();
      _loadAdditionalData(user);
    } else if (args is String) {
      _loadUserByLogin(args);
    } else {
      setState(() {
        _errorMessage = 'Invalid user data';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserByLogin(String login) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final searchResults = await _apiService.searchUsers(login);
      final user = searchResults.firstWhere(
        (u) => u.login.toLowerCase() == login.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      setState(() {
        _user = user;
      });

      _contentController.forward();
      await _loadAdditionalData(user);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdditionalData(UserModel user) async {
    // UserModel'deki verileri kullan
    setState(() {
      _skills = user.skills;
      _achievements = user.achievements;      
    });

    try {
      // Tam user detayını çek
      final fullUser = await _apiService
          .getUserDetails(user.login)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => user,
          )
          .catchError((e) => user);

      // Eğer fullUser'da daha fazla veri varsa güncelle
      bool hasMoreData = false;

      if (fullUser.skills.length > _skills.length) {
        setState(() {
          _skills = fullUser.skills;
        });
        hasMoreData = true;
      }

      if (fullUser.achievements.length > _achievements.length) {
        setState(() {
          _achievements = fullUser.achievements;
        });
        hasMoreData = true;
      }

      if (hasMoreData) {
        setState(() {
          _user = fullUser;
        });
      }

      // Rate limit için bekle
      await Future.delayed(Duration(milliseconds: 500));

      // Projects çağrısı
      final projects = await _apiService
          .getUserProjects(user.login)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => <ProjectModel>[],
          )
          .catchError((e) => <ProjectModel>[]);

      setState(() {
        _projects = projects;
        _isLoading = false;
      });

      // Coalition'ı yükle
      await Future.delayed(Duration(milliseconds: 1000));

      final coalition = await _apiService
          .getUserCoalition(user.login)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => null,
          )
          .catchError((e) => null);

      if (coalition != null) {
        setState(() {
          _coalition = coalition;
        });
      }

      // Achievements'ı yükle
      await Future.delayed(Duration(milliseconds: 500));

      final achievementsData = await _apiService
          .getUserAchievements(user.login)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => <Map<String, dynamic>>[],
          )
          .catchError((e) => <Map<String, dynamic>>[]);

      if (achievementsData.isNotEmpty) {
        final achievementModels = achievementsData
            .map((data) => AchievementModel.fromJson(data))
            .toList();
        setState(() {
          _achievements = achievementModels;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
    finally {
      setState(() => _isLoading = false); // SADECE EN SON BURADA
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage.isNotEmpty || _user == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF0a0a0a), const Color(0xFF1a0a2e),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF16213e), const Color(0xFF0f3460),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF0f3460), const Color(0xFF16213e),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF1a0a2e), const Color(0xFF0a0a0a),
                      _backgroundAnimation.value)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  final clampedValue = _contentAnimation.value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - clampedValue)),
                    child: Opacity(
                      opacity: clampedValue,
                      child: CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                FuturisticProfileHeader(
                                  user: _user!,
                                  coalition: _coalition,
                                  onCoalitionTap: () {
                                    _showCoalitionDetails();
                                  },
                                ),
                                const SizedBox(height: 24),
                                FuturisticTabBar(
                                  tabs: _tabs,
                                  selectedIndex: _selectedTab,
                                  onTabChanged: (index) =>
                                      setState(() => _selectedTab = index),
                                ),
                                const SizedBox(height: 24),
                                _buildTabContent(),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0a0a0a),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF1a0a2e),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoalitionDetails() async {
  if (_coalition == null) {
    return;
  }
  
  
  // Loading dialog göster
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _buildModernLoadingDialog(),
    );
  
  try {
    final coalitionWithUsers = await _apiService.getCoalitionWithUsers(_coalition!.id);
    
    if (coalitionWithUsers != null) {
    }
    
    // Loading dialog'u kapat
    if (mounted) AppNavigator.safeNavigateBack(context);
    
    if (coalitionWithUsers != null && mounted) {
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CoalitionModal(coalition: coalitionWithUsers),
      );
    } else if (mounted) {
      _showErrorDialog('Failed to load coalition details');
    }
  } catch (e) {
    
    if (mounted) AppNavigator.safeNavigateBack(context);
    if (mounted) _showErrorDialog('Error: $e');
  }
}

 Widget _buildModernLoadingDialog() {
  return AlertDialog(
    backgroundColor: const Color(0xFF16213e),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
          strokeWidth: 2,
        ),
        const SizedBox(width: 16),
        const Text(
          'Loading coalition details...',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}


void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF16213e),
      title: const Text('Error', style: TextStyle(color: Colors.white)),
      content: Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => AppNavigator.safeNavigateBack(context),
          child: const Text('OK', style: TextStyle(color: Color(0xFF00d4ff))),
        ),
      ],
    ),
  );
}


  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0a0a0a),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF1a0a2e),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFff006e).withValues(alpha: 0.3),
                      const Color(0xFFff8500).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to load profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => AppNavigator.safeNavigateBack(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => AppNavigator.safeNavigateBack(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _getTabContent(),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildInfoContent();
      case 1:
        return _buildProjectsContent();
      case 2:
        return _buildSkillsContent();
      case 3:
        return _buildAchievementsContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoContent() {
    return Column(
      children: [
        FuturisticInfoSection(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          gradientColors: const [Color(0xFF00d4ff), Color(0xFF0099cc)],
          children: [
            FuturisticInfoRow(
              icon: Icons.email,
              text: _user!.email,
            ),
            if (_user!.phone != null)
              FuturisticInfoRow(
                icon: Icons.phone,
                text: _user!.phone!,
              ),
            if (_user!.location != null)
              FuturisticInfoRow(
                icon: Icons.location_on,
                text: _user!.location!,
              ),
          ],
        ),
        const SizedBox(height: 16),
        FuturisticInfoSection(
          title: 'Academic Information',
          icon: Icons.school,
          gradientColors: const [Color(0xFF7209b7), Color(0xFF5a0a8a)],
          children: [
            FuturisticInfoRow(
              icon: Icons.calendar_today,
              text: 'Member since: ${_formatDate(_user!.createdAt)}',
            ),
            if (_user!.poolYear != null)
              FuturisticInfoRow(
                icon: Icons.pool,
                text: 'Pool: ${_user!.poolYear}',
              ),
            FuturisticInfoRow(
              icon: Icons.timeline,
              text: 'Cursus: ${_user!.cursusUsers.length}',
            ),
            if (_coalition != null)
              FuturisticInfoRow(
                icon: Icons.shield,
                text: 'Coalition: ${_coalition!.name}',
              ),
          ],
        ),
      ],
    );
  }
Widget _buildProjectsContent() {
  if (_projects.isEmpty) {
    return FuturisticInfoSection(
      title: 'Projects',
      icon: Icons.code,
      gradientColors: const [Color(0xFFff006e), Color(0xFFcc0055)],
      children: const [
        FuturisticInfoRow(
          icon: Icons.info_outline,
          text: 'No projects available',
        ),
      ],
    );
  }

  return Column(
    children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFff006e), Color(0xFFcc0055)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.code, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Projects (${_projects.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      
      // Scrollable Projects List
      Container(
        height: 400, // Sabit yükseklik
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProjectIcon(project),
                    color: _getProjectColor(project),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (project.finalMark != null)
                          Text(
                            'Score: ${project.finalMark}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _getProjectColor(project),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _getProjectColor(project).withValues(alpha: 0.2),
                    ),
                    child: Text(
                      _getProjectStatus(project),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getProjectColor(project),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildSkillsContent() {
  final skills = _skills.isNotEmpty ? _skills : _user?.skills ?? [];

  if (skills.isEmpty) {
    return FuturisticInfoSection(
      title: 'Skills',
      icon: Icons.psychology,
      gradientColors: const [Color(0xFF7209b7), Color(0xFFff006e)],
      children: const [
        FuturisticInfoRow(
          icon: Icons.info_outline,
          text: 'No skills data available',
        ),
      ],
    );
  }

  return Column(
    children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF7209b7), Color(0xFFff006e)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Skills (${skills.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      
      // Scrollable Skills Grid
      Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7209b7).withValues(alpha: 0.3),
                    Color(0xFFff006e).withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lv ${skill.level.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildAchievementsContent() {
  final achievements = _achievements.isNotEmpty ? _achievements : _user?.achievements ?? [];

  if (achievements.isEmpty) {
    return FuturisticInfoSection(
      title: 'Achievements',
      icon: Icons.emoji_events,
      gradientColors: const [Color(0xFF00d4ff), Color(0xFF7209b7)],
      children: const [
        FuturisticInfoRow(
          icon: Icons.info_outline,
          text: 'No achievements yet',
        ),
      ],
    );
  }

  return Column(
    children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Achievements (${achievements.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      
      // Scrollable Achievements List
      Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00d4ff).withValues(alpha: 0.2),
                    Color(0xFF7209b7).withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (achievement.description.isNotEmpty)
                          Text(
                            achievement.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF00d4ff).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      achievement.tier.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF00d4ff),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Yardımcı fonksiyonlar
Color _getProjectColor(ProjectModel project) {
  if (project.finalMark != null) {
    final mark = project.finalMark!;
    if (mark >= 100) return Color(0xFF00FF00); // Yeşil - Mükemmel
    if (mark >= 80) return Color(0xFF00d4ff);  // Mavi - İyi
    if (mark >= 60) return Color(0xFFFFD700); // Altın - Orta
    return Color(0xFFFF6B6B); // Kırmızı - Düşük
  }
  return Color(0xFF888888); // Gri - Belirsiz
}

String _getProjectStatus(ProjectModel project) {
  if (project.finalMark != null) {
    final mark = project.finalMark!;
    if (mark >= 100) return "EXCELLENT";
    if (mark >= 80) return "GOOD";
    if (mark >= 60) return "PASS";
    return "FAIL";
  }
  return "IN PROGRESS";
}
String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
IconData _getProjectIcon(ProjectModel project) {
  // Proje adına göre ikon belirleme
  final projectName = project.name.toLowerCase();
  
  // Web projeleri
  if (projectName.contains('web') || 
      projectName.contains('django') || 
      projectName.contains('react') || 
      projectName.contains('html') ||
      projectName.contains('css') ||
      projectName.contains('javascript')) {
    return Icons.web;
  }
  
  // Mobile projeleri
  if (projectName.contains('mobile') || 
      projectName.contains('flutter') || 
      projectName.contains('swifty') ||
      projectName.contains('android') ||
      projectName.contains('ios')) {
    return Icons.phone_android;
  }
  
  // Database projeleri
  if (projectName.contains('sql') || 
      projectName.contains('database') || 
      projectName.contains('db')) {
    return Icons.storage;
  }
  
  // Network/System projeleri
  if (projectName.contains('network') || 
      projectName.contains('server') || 
      projectName.contains('system') ||
      projectName.contains('docker') ||
      projectName.contains('nginx')) {
    return Icons.lan;
  }
  
  // Security projeleri
  if (projectName.contains('security') || 
      projectName.contains('crypto') || 
      projectName.contains('auth')) {
    return Icons.security;
  }
  
  // Graphics/Game projeleri
  if (projectName.contains('game') || 
      projectName.contains('graphic') || 
      projectName.contains('opengl') ||
      projectName.contains('raycast') ||
      projectName.contains('cub3d') ||
      projectName.contains('fdf')) {
    return Icons.games;
  }
  
  // C/C++ projeleri
  if (projectName.contains('libft') || 
      projectName.contains('printf') || 
      projectName.contains('cpp') ||
      projectName.contains('c++') ||
      projectName.contains('minishell') ||
      projectName.contains('pipex')) {
    return Icons.code;
  }
  
  // Algorithm projeleri
  if (projectName.contains('algorithm') || 
      projectName.contains('sort') || 
      projectName.contains('push_swap') ||
      projectName.contains('philosopher')) {
    return Icons.psychology;
  }
  
  // Status'e göre ikon
  if (project.finalMark != null) {
    if (project.finalMark! >= 100) {
      return Icons.star; // Mükemmel
    } else if (project.finalMark! >= 80) {
      return Icons.check_circle; // Başarılı
    } else if (project.finalMark! >= 60) {
      return Icons.check; // Geçti
    } else {
      return Icons.cancel; // Başarısız
    }
  }
  
  // In progress projeler
  if (project.status == 'in_progress') {
    return Icons.timelapse;
  }
  
  // Varsayılan ikon
  return Icons.assignment;
}
}
