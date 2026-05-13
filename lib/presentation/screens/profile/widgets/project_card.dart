import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/project_model.dart';

/// Single project card showing name, status badge, and final mark.
///
/// Badges:
/// - Validated → green
/// - In Progress → yellow
/// - Failed → red
class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final List<ProjectModel> children;
  final bool isSubProject;

  const ProjectCard({
    super.key,
    required this.project,
    this.children = const [],
    this.isSubProject = false,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.children.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: hasChildren ? () => setState(() => _isExpanded = !_isExpanded) : null,
          child: Container(
            padding: EdgeInsets.all(widget.isSubProject ? 12 : 16),
            decoration: BoxDecoration(
              color: widget.isSubProject ? Colors.transparent : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
              border: widget.isSubProject 
                  ? null 
                  : Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.name,
                        style: (widget.isSubProject ? AppTypography.bodyLg : AppTypography.bodyLg).copyWith(
                          color: Colors.white,
                          fontWeight: widget.isSubProject ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(project: widget.project),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (hasChildren)
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.muted,
                  )
                else
                  _FinalMark(project: widget.project),
              ],
            ),
          ),
        ),
        if (_isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Column(
              children: widget.children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProjectCard(project: child, isSubProject: true),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

// ── Status Badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ProjectModel project;
  const _StatusBadge({required this.project});

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = _resolveStatus();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelCode.copyWith(color: textColor),
      ),
    );
  }

  (String, Color, Color) _resolveStatus() {
    if (project.status == ProjectStatus.finished && project.validated) {
      return (
        'Validated',
        const Color(0xFF1B5E20).withValues(alpha: 0.3),
        const Color(0xFF66BB6A),
      );
    }
    if (project.isFailed) {
      return (
        'Failed',
        AppColors.primaryRed.withValues(alpha: 0.2),
        AppColors.primaryRed,
      );
    }
    if (project.status == ProjectStatus.inProgress) {
      return (
        'In Progress',
        const Color(0xFFF57F17).withValues(alpha: 0.3),
        const Color(0xFFFFCA28),
      );
    }
    return (
      'Team Finding',
      const Color(0xFF00ACC1).withValues(alpha: 0.2),
      const Color(0xFF26C6DA),
    );
  }
}

// ── Final Mark ──────────────────────────────────────────────────────────────

class _FinalMark extends StatelessWidget {
  final ProjectModel project;
  const _FinalMark({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.finalMark == null) {
      return Text(
        '-',
        style: AppTypography.headlineMd.copyWith(
          color: Colors.grey,
        ),
      );
    }

    final color = project.validated
        ? const Color(0xFF66BB6A)
        : project.isFailed
            ? AppColors.primaryRed
            : AppColors.onSurface;

    return Text(
      project.finalMark.toString(),
      style: AppTypography.headlineMd.copyWith(color: color),
    );
  }
}
