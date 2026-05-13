import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Single skill progress bar row.
///
/// Shows skill name, percentage label, and a gradient-filled progress bar.
class SkillBar extends StatelessWidget {
  final String name;
  final double level;

  const SkillBar({
    super.key,
    required this.name,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize to 0–1 range (42 API skills max at ~21)
    final progress = (level / 21).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodyLg.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: AppTypography.labelCode.copyWith(
                color: const Color(0xFF8E97FD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress bar
        SizedBox(
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Track
                Container(
                  color: const Color(0xFF16213E),
                ),
                // Fill
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.progressGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
