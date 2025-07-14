import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peer42/src/core/models/slot_model.dart';
import 'package:peer42/src/core/services/api_service.dart';
import 'package:peer42/src/core/services/slot_booking_service.dart';
import 'package:peer42/src/features/evaluation/widgets/slot_creation_dialog.dart';

class EvaluationSlotPage extends StatefulWidget {
  const EvaluationSlotPage({Key? key}) : super(key: key);

  @override
  State<EvaluationSlotPage> createState() => _EvaluationSlotPageState();
}

class _EvaluationSlotPageState extends State<EvaluationSlotPage> 
    with TickerProviderStateMixin {
  final EvaluationSlotService _slotService = EvaluationSlotService();
  
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<EvaluationSlotModel> _userSlots = [];
  List<ScaleTeamModel> _userEvaluations = [];
  
  // Animation controllers
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Setup animations
    _setupAnimations();
    
    _loadInitialData();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadUserSlots(),
        _loadUserEvaluations(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserSlots() async {
    try {
      final slotsData = await _slotService.getUserSlots();
      setState(() {
        _userSlots = slotsData
            .map((data) => EvaluationSlotModel.fromJson(data))
            .toList();
      });
    } catch (e) {
      print('Error loading user slots: $e');
    }
  }

  Future<void> _loadUserEvaluations() async {
    try {
      final evaluationsData = await _slotService.getUserEvaluations();
      setState(() {
        _userEvaluations = evaluationsData
            .map((data) => ScaleTeamModel.fromJson(data))
            .toList();
      });
    } catch (e) {
      print('Error loading user evaluations: $e');
    }
  }

  Future<void> _createSlot() async {
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => SlotCreationDialog(),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await _slotService.createEvaluationSlot(
          beginAt: result['beginAt']!,
          endAt: result['endAt']!,
        );
        
        _showSnackBar('Evaluation slot created successfully!');
        
        // Refresh data
        await _loadUserSlots();
        
      } catch (e) {
        _showSnackBar('Failed to create slot: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSlot(EvaluationSlotModel slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: Text('Delete Slot', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this evaluation slot?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF00d4ff))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFff006e)),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        await _slotService.deleteSlot(slot.id);
        
        _showSnackBar('Slot deleted successfully!');
        
        // Refresh data
        await _loadUserSlots();
        
      } catch (e) {
        _showSnackBar('Failed to delete slot: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFff006e) : const Color(0xFF00d4ff),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMySlotsTab(),
                        _buildEvaluationsTab(),
                        _buildInfoTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _createSlot,
              icon: Icon(Icons.add),
              label: Text('Create Slot'),
              backgroundColor: const Color(0xFF00d4ff),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                  ).createShader(bounds),
                  child: const Text(
                    'Evaluations',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your evaluation slots and appointments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
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
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        // Tab göstergesini tüm tab genişliğine uzatma
        indicatorSize: TabBarIndicatorSize.tab,
        // Tab uzayınca indikatör de uzar, TabBarIndicatorSize.label kullanılıyorsa sadece yazı kadar olur
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        // Tab'leri eşit genişlikte yapar
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        // Tüm TabBar genişliğini tab'lere eşit dağıtır
        tabAlignment: TabAlignment.fill,
        tabs: [
          Tab(icon: Icon(Icons.schedule), text: 'My Slots'),
          Tab(icon: Icon(Icons.assignment), text: 'Evaluations'),
          Tab(icon: Icon(Icons.info), text: 'Info'),
        ],
      ),
    );
  }

  Widget _buildMySlotsTab() {
    return RefreshIndicator(
      onRefresh: _loadUserSlots,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Color(0xFFff006e)),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00d4ff),
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _userSlots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_outlined, size: 64, color: Colors.white54),
                          SizedBox(height: 16),
                          Text(
                            'No evaluation slots created',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create a slot to be available for evaluations',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _createSlot,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00d4ff),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.add),
                            label: Text('Create First Slot'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _userSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _userSlots[index];
                        return _buildSlotCard(slot, index);
                      },
                    ),
    );
  }

  Widget _buildSlotCard(EvaluationSlotModel slot, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _getStatusColor(slot.status),
                    ),
                    child: Icon(
                      _getStatusIcon(slot.status),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(slot.beginAt)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(slot.beginAt)} - ${DateFormat('HH:mm').format(slot.endAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _getStatusColor(slot.status).withOpacity(0.2),
                              ),
                              child: Text(
                                slot.statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(slot.status),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${slot.duration.inMinutes} minutes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (slot.canCancel)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.withOpacity(0.2),
                      ),
                      child: IconButton(
                        onPressed: () => _deleteSlot(slot),
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: 'Delete slot',
                        constraints: BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvaluationsTab() {
    return RefreshIndicator(
      onRefresh: _loadUserEvaluations,
      color: Color(0xFF00d4ff),
      child: _userEvaluations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'No evaluations scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your evaluation appointments will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _userEvaluations.length,
              itemBuilder: (context, index) {
                final evaluation = _userEvaluations[index];
                return _buildEvaluationCard(evaluation, index);
              },
            ),
    );
  }

  Widget _buildEvaluationCard(ScaleTeamModel evaluation, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          _getEvaluationStatusColor(evaluation.status),
                          _getEvaluationStatusColor(evaluation.status).withBlue(
                            (_getEvaluationStatusColor(evaluation.status).blue + 40).clamp(0, 255)
                          ),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getEvaluationStatusIcon(evaluation.status),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evaluation.projectName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (evaluation.beginAt != null) ...[
                          SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy HH:mm').format(evaluation.beginAt!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Corrector: ${evaluation.correctorLogin}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _getEvaluationStatusColor(evaluation.status).withOpacity(0.2),
                              ),
                              child: Text(
                                _getEvaluationStatusText(evaluation.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getEvaluationStatusColor(evaluation.status),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (evaluation.hasScore)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFF00d4ff).withOpacity(0.2),
                                ),
                                child: Text(
                                  'Score: ${evaluation.finalMark}/100',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF00d4ff),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'What are Evaluation Slots?',
            content: 'Evaluation slots are time intervals when you declare yourself available to evaluate other students\' projects. When you create a slot, you join the evaluation pool.',
            icon: Icons.info,
            color: Color(0xFF00d4ff),
            index: 0,
          ),
          _buildInfoCard(
            title: 'Slot Requirements',
            content: '• Minimum duration: 30 minutes\n• Can be set 30 minutes to 2 weeks in advance\n• Time granularity: 15 minutes\n• Automatically scaled to 15-minute intervals',
            icon: Icons.schedule,
            color: Color(0xFF7209b7),
            index: 1,
          ),
          _buildInfoCard(
            title: 'How it Works',
            content: '1. Create an evaluation slot with your available time\n2. Students can book your slot for their project evaluation\n3. You\'ll receive notification when slot is booked\n4. Conduct the evaluation at the scheduled time',
            icon: Icons.how_to_reg,
            color: Color(0xFF00d4ff),
            index: 2,
          ),
          _buildInfoCard(
            title: 'Cancellation Policy',
            content: 'You can cancel unbooked slots up to 30 minutes before they start. Once a slot is booked by a student, it cannot be cancelled.',
            icon: Icons.cancel,
            color: Color(0xFFff006e),
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Color(0xFF00d4ff);
      case SlotStatus.booked:
        return Color(0xFF7209b7);
      case SlotStatus.active:
        return Color(0xFFFFA726);
      case SlotStatus.completed:
        return Color(0xFF607D8B);
    }
  }

  IconData _getStatusIcon(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Icons.schedule;
      case SlotStatus.booked:
        return Icons.bookmark;
      case SlotStatus.active:
        return Icons.play_circle;
      case SlotStatus.completed:
        return Icons.check_circle;
    }
  }

  Color _getEvaluationStatusColor(EvaluationStatus status) {
    switch (status) {
      case EvaluationStatus.scheduled:
        return Color(0xFF7209b7);
      case EvaluationStatus.inProgress:
        return Color(0xFFFFA726);
      case EvaluationStatus.completed:
        return Color(0xFF00d4ff);
    }
  }

  IconData _getEvaluationStatusIcon(EvaluationStatus status) {
    switch (status) {
      case EvaluationStatus.scheduled:
        return Icons.schedule;
      case EvaluationStatus.inProgress:
        return Icons.play_circle;
      case EvaluationStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getEvaluationStatusText(EvaluationStatus status) {
    switch (status) {
      case EvaluationStatus.scheduled:
        return 'Scheduled';
      case EvaluationStatus.inProgress:
        return 'In Progress';
      case EvaluationStatus.completed:
        return 'Completed';
    }
  }
}