import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Full-screen error view with wifi-off icon, message and retry button.
/// Matches the network_error_snackbar design.
class NetworkErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const NetworkErrorView({
    super.key,
    this.title = 'No Connection',
    this.message = 'Check your internet and try again',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow
            _buildIcon(),
            const SizedBox(height: 32),
            // Title
            Text(title, style: AppTypography.headlineLg),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.tertiaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Retry button
            if (onRetry != null) _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.2),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
          // Icon container
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.15),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.primaryRed,
            ),
          ),
          // Decorative dots
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              'Try Again',
              style: AppTypography.labelCode.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
