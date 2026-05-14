import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Animated "no results found" widget shown when a search query
/// returns zero results from the API.
///
/// Features a pulsing search icon with concentric rings,
/// a clear message, and a subtle hint to try different keywords.
class SearchNotFound extends StatefulWidget {
  final String query;
  const SearchNotFound({super.key, required this.query});

  @override
  State<SearchNotFound> createState() => _SearchNotFoundState();
}

class _SearchNotFoundState extends State<SearchNotFound>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon with rings
              _buildAnimatedIcon(),
              const SizedBox(height: 32),
              // Title
              Text(
                'No results found',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              // Query display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 16,
                      color: AppColors.primaryRed.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '"${widget.query}"',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Hint text
              Text(
                'Try a different username or check the spelling.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.muted.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(
                      alpha: 0.05 + pulseValue * 0.08,
                    ),
                    width: 1,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(
                      alpha: 0.08 + pulseValue * 0.12,
                    ),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner circle with gradient
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryRed.withValues(alpha: 0.12),
                      AppColors.surfaceContainer.withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(
                      alpha: 0.15 + pulseValue * 0.1,
                    ),
                    width: 1.5,
                  ),
                ),
              ),
              // Icon
              Icon(
                Icons.person_search_rounded,
                size: 40,
                color: AppColors.primaryRed.withValues(
                  alpha: 0.5 + pulseValue * 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
