import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../router/app_router.dart';

/// Custom 404 / Page Not Found screen.
class NotFoundScreen extends StatelessWidget {
  final Exception? error;

  const NotFoundScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.splash);
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 404 Header with Lilita One font
              Text(
                '404',
                style: GoogleFonts.lilitaOne(
                  fontSize: 120,
                  color: AppColors.primaryRed,
                  height: 1,
                ),
              ),
              const SizedBox(height: 24),
              
              // Decorative icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_off_rounded,
                  size: 64,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Lost in the Network',
                style: AppTypography.headlineLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'The page you are looking for does not exist or has been moved.',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Optional error details
              if (error != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    error.toString(),
                    style: AppTypography.labelCode.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Return Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.splash),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(
                    'Return Home',
                    style: AppTypography.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primaryRed.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
