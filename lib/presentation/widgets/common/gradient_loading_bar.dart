import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated gradient loading bar — red→lavender gradient fill
/// that slides left-to-right continuously.
class GradientLoadingBar extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final bool repeat;

  const GradientLoadingBar({
    super.key,
    this.width = 200,
    this.height = 4,
    this.duration = const Duration(milliseconds: 1500),
    this.repeat = true,
  });

  @override
  State<GradientLoadingBar> createState() => _GradientLoadingBarState();
}

class _GradientLoadingBarState extends State<GradientLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            // Track
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            // Animated fill
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _controller.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
