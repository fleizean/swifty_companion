import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';

/// Bottom sheet card for the login screen.
///
/// Contains: handle bar, app logo, heading, subtitle,
/// gradient "Login with 42" button, and privacy footer.
class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Handle bar
                  const _HandleBar(),
                  const SizedBox(height: 32),
                  // Heading
                  Text(
                    'Welcome to Peer42',
                    style: AppTypography.headlineLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  SizedBox(
                    width: 280,
                    child: Text(
                      'Sign in with your 42 Intra account to explore student profiles.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.tertiaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // Login button
                  const _LoginButton(),
                  const SizedBox(height: 16),
                  // Privacy footer
                  const _PrivacyFooter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Gaming-style Name Tag and Arrow
        Positioned(
          top: -80, // Moved slightly down
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Norminette',
                style: AppTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontSize: 13, // Made smaller
                  shadows: [
                    Shadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                    const Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
              // Downward Arrow Indicator
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16, // Made smaller
              ),
            ],
          ),
        ),
        // Splash Cat
        Positioned(
          top: -77, // Sits exactly on the bottom sheet border
          child: Lottie.asset(
            'assets/animations/splash_cat.json',
            height: 96,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// ── Handle Bar ──────────────────────────────────────────────────────────────

class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Gradient Login Button ───────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.state == AuthState.loading;

    return GestureDetector(
      onTap: isLoading ? null : () => authProvider.login(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/logo_42_white.png',
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Login with 42',
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Privacy Footer ──────────────────────────────────────────────────────────

class _PrivacyFooter extends StatelessWidget {
  const _PrivacyFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome, // A starry, universe-like icon
          size: 14,
          color: AppColors.tertiaryContainer.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Text(
          'The answer to life, the universe, and everything.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.tertiaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
