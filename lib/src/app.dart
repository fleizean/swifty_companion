
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peer42/src/features/evaluation/pages/evaluation_slot_page.dart';

import 'core/services/oauth2_service.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/app_navigator.dart';
import 'features/auth/pages/oauth2_login_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/search/pages/search_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/main/pages/main_navigation_page.dart'; // ← YENİ EKLENEN

class Peer42App extends StatelessWidget {
  const Peer42App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Peer42',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().darkTheme,
      navigatorKey: AppNavigator.navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainNavigationPage(), // ← DEĞİŞTİ: SearchPage yerine MainNavigationPage
        '/search': (context) => const SearchPage(), // ← Artık direkt erişim (opsiyonel)
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/login': (context) => const OAuth2LoginPage(),
        '/evaluation-slots': (context) => const EvaluationSlotPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final OAuth2Service _oauth2Service = OAuth2Service();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final isAuthenticated = await _oauth2Service.isAuthenticated();
      
      if (mounted) {
        if (isAuthenticated) {
          // User is logged in, go to main navigation (bottom nav ile search sayfası)
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // User needs to login
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      // In case of error, go to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'Peer42',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Loading Indicator
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              
              // Loading Text
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}