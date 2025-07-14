// lib/src/features/settings/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:peer42/src/core/utils/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/oauth2_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  final _oauth2Service = OAuth2Service();

  bool _isLoading = false;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // Scope debug state variables
  List<String> _currentScopes = [];
  bool _hasProjectsScope = false;
  bool _isLoadingScopes = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  // Load scope information
  Future<void> _loadScopeInfo() async {
    setState(() {
      _isLoadingScopes = true;
    });

    try {
      final scopes = await _oauth2Service.getCurrentScopes();
      final hasProjects = await _oauth2Service.hasProjectsScope();
      
      print('🔍 Current scopes: $scopes');
      print('📋 Has projects scope: $hasProjects');
      
      if (hasProjects) {
        print('✅ Evaluation slots should work!');
        _showSnackBar('✅ API Scopes: Projects permission is active', isError: false);
      } else {
        print('❌ Evaluation slots will show 403 error');
        _showSnackBar('❌ API Scopes: Projects permission is missing!', isError: true);
      }
      
      _showSnackBar('Current scopes: ${scopes.join(", ")}', 
        isError: false, 
        duration: const Duration(seconds: 5)
      );
      
      setState(() {
        _currentScopes = scopes;
        _hasProjectsScope = hasProjects;
      });
    } catch (e) {
      print('❗ Error loading scope info: $e');
      _showSnackBar('❗ Error loading API scopes: $e', isError: true);
    } finally {
      setState(() {
        _isLoadingScopes = false;
      });
    }
  }

  void _showSnackBar(String message, {
    bool isError = false, 
    Duration duration = const Duration(seconds: 3)
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await _showLogoutDialog();
    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _oauth2Service.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to logout: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFff006e)),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _buildSettingsContent(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppNavigator.safeNavigateBack(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
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
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
            ).createShader(bounds),
            child: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // API Debug Button - Always visible
          GestureDetector(
            onTap: _loadScopeInfo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoadingScopes 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.api, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'API Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API Debug Section - Always visible
          _buildSectionTitle('API Status'),
          const SizedBox(height: 16),
          _buildApiStatusCard(),
          const SizedBox(height: 32),
          
          // Account Section
          _buildSectionTitle('Account'),
          const SizedBox(height: 16),
          _buildAccountSection(),
          const SizedBox(height: 32),
          
          // About Section
          _buildSectionTitle('About'),
          const SizedBox(height: 16),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildApiStatusCard() {
    Color statusColor = _currentScopes.isEmpty 
        ? Colors.grey 
        : (_hasProjectsScope ? Colors.green : Colors.red);
        
    String statusText = _currentScopes.isEmpty
        ? "Tap API Check to see your permissions"
        : (_hasProjectsScope 
            ? "Projects permission active ✅" 
            : "Projects permission missing ❌");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                  ),
                ),
                child: const Icon(
                  Icons.api,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Permission Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_currentScopes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            
            Text(
              'Available Permissions:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _currentScopes.map((scope) {
                final isProjectsScope = scope == 'projects';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isProjectsScope 
                        ? Colors.green.withOpacity(0.2)
                        : const Color(0xFF00d4ff).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isProjectsScope 
                          ? Colors.green
                          : const Color(0xFF00d4ff),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    scope,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isProjectsScope 
                          ? Colors.green
                          : const Color(0xFF00d4ff),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action button
          ElevatedButton.icon(
            onPressed: _loadScopeInfo,
            icon: _isLoadingScopes 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: Text(_isLoadingScopes ? 'Checking...' : 'Check API Permissions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4ff),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Warning for missing projects scope
          if (_currentScopes.isNotEmpty && !_hasProjectsScope) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Permission Issue Detected',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Projects scope is required for evaluation slots. Please logout and login again with all permissions.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await _oauth2Service.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Logout and Re-login'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        _buildSettingsCard(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          onTap: _logout,
          iconGradient: const [Color(0xFFff006e), Color(0xFFff8500)],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        _buildSettingsCard(
          icon: Icons.info_outline,
          title: 'Version',
          subtitle: '1.0.0',
          onTap: null,
          iconGradient: const [Color(0xFF00d4ff), Color(0xFF7209b7)],
        ),
        const SizedBox(height: 12),
        _buildSettingsCard(
          icon: Icons.code,
          title: 'Developed by',
          subtitle: 'eyagiz',
          onTap: () async {
            final Uri url = Uri.parse('https://fleizean.vercel.app');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          },
          iconGradient: const [Color(0xFF7209b7), Color(0xFF00d4ff)],
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required List<Color> iconGradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: iconGradient,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
