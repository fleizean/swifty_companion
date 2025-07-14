import 'package:flutter/material.dart';
import '../../search/pages/search_page.dart';
import '../../evaluation/pages/evaluation_slot_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../settings/pages/settings_page.dart';
import '../../../core/services/api_service.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final ApiService _apiService = ApiService();
  int _currentIndex = 0;
  bool _isLoadingProfile = false;

  // Sayfalar listesi - Search ana sayfa olarak
  final List<Widget> _pages = [
    const SearchPage(), // Ana sayfa (home yerine)
    const EvaluationSlotPage(), // Evaluation Slots
    const SizedBox(), // Profile - dinamik olarak yüklenecek
    const SettingsPage(), // Settings
  ];

  // Tab bilgileri - Dark theme'e uygun
  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'Search',
      tooltip: 'Search students',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.schedule_outlined),
      activeIcon: Icon(Icons.schedule),
      label: 'Slots',
      tooltip: 'Evaluation slots',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
      tooltip: 'My profile',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
      tooltip: 'App settings',
    ),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Profile tab'ına tıklandığında
      _navigateToMyProfile();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _navigateToMyProfile() async {
    // Loading göster
    setState(() {
      _isLoadingProfile = true;
      _currentIndex = 2; // Profile tab'ını aktif göster
    });
    
    try {
      // Current user'ı al
      final currentUserData = await _apiService.getCurrentUser();
      
      if (currentUserData != null && mounted) {
        // Profile sayfasına git - route ile
        Navigator.pushNamed(
          context,
          '/profile',
          arguments: currentUserData, // Map<String, dynamic> olarak gönder
        );
        
        // Tab'ı geri çevir (Profile sayfası ayrı route olduğu için)
        setState(() {
          _currentIndex = 0; // Search tab'ına geri dön
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load your profile: $e');
        // Hata durumunda Search tab'ına geri dön
        setState(() {
          _currentIndex = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _currentIndex = 3; // Settings tab'ına git
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _pages[0], // SearchPage
          _pages[1], // EvaluationSlotPage
          _buildProfileTab(), // Profile loading state
          _pages[3], // SettingsPage
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF16213e).withOpacity(0.9),
              const Color(0xFF0f3460).withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00d4ff).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            // Profile tab'ında loading göster
            if (index == 2 && _isLoadingProfile) {
              return BottomNavigationBarItem(
                icon: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentIndex == 2 
                          ? const Color(0xFF00d4ff) 
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                label: item.label,
                tooltip: 'Loading profile...',
              );
            }
            
            return item;
          }).toList(),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00d4ff),
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          enableFeedback: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    // Profile tab'ı hiç görünmeyecek çünkü route ile açılıyor
    return Container(
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
            ),
            SizedBox(height: 16),
            Text(
              'Redirecting to profile...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}