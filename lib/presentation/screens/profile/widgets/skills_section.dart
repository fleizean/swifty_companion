import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/skill_model.dart';
import 'skill_bar.dart';

/// Skills section with heading and list of gradient skill bars.
///
/// Features an expandable list if there are many skills.
class SkillsSection extends StatefulWidget {
  final List<SkillModel> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  bool _isExpanded = false;
  static const int _initialItemCount = 4;

  @override
  Widget build(BuildContext context) {
    if (widget.skills.isEmpty) return const SizedBox.shrink();

    final hasMore = widget.skills.length > _initialItemCount;
    final displayCount = _isExpanded || !hasMore 
        ? widget.skills.length 
        : _initialItemCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: AppTypography.headlineMd.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) => SkillBar(
            name: widget.skills[index].name,
            level: widget.skills[index].level,
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.secondary,
              ),
              label: Text(
                _isExpanded 
                    ? 'Show Less' 
                    : 'Show All ${widget.skills.length} Skills',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

