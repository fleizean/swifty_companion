import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'widgets/login_bottom_sheet.dart';

/// Login screen with top illustration area and bottom sheet card.
///
/// Layout (matching design):
/// - Top 50% area: gradient background with logo + glow orbs
/// - Bottom sheet: rounded-top card with login CTA
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Column(
        children: [
          // Top illustration area
          const _IllustrationArea(),
          // Bottom sheet card
          const Expanded(child: LoginBottomSheet()),
        ],
      ),
    );
  }
}

// ── Top Illustration Area ───────────────────────────────────────────────────

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.45;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceContainerLowest,
                  AppColors.surfaceContainerLow,
                ],
              ),
            ),
          ),
          // Decorative glow orbs
          Positioned(
            top: 80,
            left: 30,
            child: _GlowOrb(
              size: 60,
              color: AppColors.primaryRed.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _GlowOrb(
              size: 40,
              color: AppColors.secondary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 140,
            left: 60,
            child: _GlowOrb(
              size: 50,
              color: AppColors.secondaryContainer.withValues(alpha: 0.12),
            ),
          ),
          // Centered app logo + title
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withValues(alpha: 0.25),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // App title
                Text(
                  'Peer42',
                  style: AppTypography.display.copyWith(
                    color: AppColors.primaryRed,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          // Bottom fade overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.surfaceContainerLow],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.6)],
      ),
    );
  }
}
