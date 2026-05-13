import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Empty state illustration shown when there are no search results.
///
/// Large circle with pulsing border animation and a globe/search icon,
/// matching the design's center illustration.
class SearchEmptyState extends StatefulWidget {
  const SearchEmptyState({super.key});

  @override
  State<SearchEmptyState> createState() => _SearchEmptyStateState();
}

class _SearchEmptyStateState extends State<SearchEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 256,
        height: 256,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing border ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryRed.withValues(
                        alpha: 0.1 + _pulseController.value * 0.15,
                      ),
                      width: 1,
                    ),
                  ),
                );
              },
            ),
            // Inner circle
            Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer.withValues(alpha: 0.8),
              ),
            ),
            // Globe icon
            Icon(
              Icons.travel_explore,
              size: 80,
              color: AppColors.primaryRed.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
