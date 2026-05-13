import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/gradient_loading_bar.dart';

/// Splash screen shown at app startup while checking stored token.
///
/// Layout (matching design):
/// - Radial glow background
/// - Centered app logo with gradient shadow
/// - "Peer42" display text + "42 Network Explorer" italic tagline
/// - Animated gradient loading bar at bottom
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The AuthProvider handles the redirect via GoRouter's redirect logic,
    // so splash just needs to render and wait.
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Radial glow background
            _RadialGlow(),
            // Main content
            _SplashContent(),
            // Bottom loading bar
            _BottomLoader(),
          ],
        ),
      ),
    );
  }
}

// ── Radial Glow Background ──────────────────────────────────────────────────

class _RadialGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 256,
          height: 256,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withValues(alpha: 0.2),
                blurRadius: 100,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main Splash Content (Logo + Typography) ────────────────────────────────

class _SplashContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App logo with gradient shadow
          _AppLogo(),
          const SizedBox(height: 32),
          // App title
          Text(
            'Peer42',
            style: AppTypography.display.copyWith(
              color: AppColors.primaryRed,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Logo ────────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        children: [
          // Gradient glow behind logo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryRed.withValues(alpha: 0.3),
                    AppColors.secondary.withValues(alpha: 0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Logo image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 128,
                  height: 128,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Loading Bar with Dynamic Status ────────────────────────────────────

class _BottomLoader extends StatefulWidget {
  @override
  State<_BottomLoader> createState() => _BottomLoaderState();
}

class _BottomLoaderState extends State<_BottomLoader> {
  final List<String> _loadingMessages = [
    'Connecting to 42 Network...',
    'Checking secure tokens...',
    'Authenticating peer...',
    'Waking up Norminette...',
    'Loading clusters...',
    'Almost ready...',
  ];

  int _currentIndex = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startMessageRotation();
  }

  void _startMessageRotation() async {
    // Total duration is 5 seconds. We have 6 messages. 
    // Show each message for roughly 5000 / 6 ≈ 833ms
    const interval = Duration(milliseconds: 833);
    
    for (int i = 0; i < _loadingMessages.length - 1; i++) {
      await Future.delayed(interval);
      if (_isDisposed) return;
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dynamic Status Message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _loadingMessages[_currentIndex],
                  key: ValueKey<int>(_currentIndex),
                  style: AppTypography.labelCode.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Loading Bar
              const Center(
                child: GradientLoadingBar(
                  width: 200, 
                  height: 4,
                  duration: Duration(seconds: 5),
                  repeat: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
