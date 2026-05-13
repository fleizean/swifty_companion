import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/project_model.dart';
import 'project_card.dart';
import '../../../../data/models/user_model.dart';

/// Projects section with heading and list of project cards.
///
/// Features an expandable list if there are many projects.
class ProjectsSection extends StatefulWidget {
  final UserModel user;

  const ProjectsSection({super.key, required this.user});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  bool _isExpanded = false;
  int _selectedStatusIndex = 0;
  int? _selectedCursusId;
  static const int _initialItemCount = 4;

  final List<String> _statusFilters = [
    'All',
    'In Progress',
    'Validated',
    'Failed',
    'Team Finding'
  ];

  @override
  void initState() {
    super.initState();
    // Prioritize 42cursus as the default selection
    if (widget.user.cursuses.isNotEmpty) {
      final coreCursus = widget.user.cursuses.firstWhere(
        (c) => c.slug == '42cursus',
        orElse: () => widget.user.cursuses.first,
      );
      _selectedCursusId = coreCursus.id;
    }
  }

  List<ProjectModel> get _filteredProjects {
    var list = widget.user.projects;

    // 1. Filter by Cursus
    if (_selectedCursusId != null) {
      list = list.where((p) => p.cursusIds.contains(_selectedCursusId)).toList();
    }

    // 2. Filter by Status
    if (_selectedStatusIndex != 0) {
      final filter = _statusFilters[_selectedStatusIndex];
      list = list.where((p) {
        if (filter == 'In Progress') return p.status == ProjectStatus.inProgress;
        if (filter == 'Validated') return p.status == ProjectStatus.finished && p.validated;
        if (filter == 'Failed') return p.isFailed;
        if (filter == 'Team Finding') {
          return p.status == ProjectStatus.searchingGroup || 
                 p.status == ProjectStatus.unknown || 
                 p.status == ProjectStatus.parent;
        }
        return true;
      }).toList();
    }

    return list;
  }

  /// Groups projects by their parent ID.
  /// Returns only top-level projects for the current filter.
  List<ProjectModel> get _topLevelProjects {
    final list = _filteredProjects;
    final allIds = list.map((p) => p.id).toSet();
    
    // Top-level projects are those with no parent OR whose parent is not in the filtered list
    return list.where((p) => p.parentId == null || !allIds.contains(p.parentId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.projects.isEmpty) return const SizedBox.shrink();

    final displayList = _topLevelProjects;
    final hasMore = displayList.length > _initialItemCount;
    final displayCount = _isExpanded || !hasMore 
        ? displayList.length 
        : _initialItemCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Projects',
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
        const SizedBox(height: 24),
        
        // Cursus Filter
        if (widget.user.cursuses.length > 1) ...[
          _buildCursusFilters(),
          const SizedBox(height: 16),
        ],

        // Status Filter
        _buildStatusFilters(),
        const SizedBox(height: 16),

        displayList.isEmpty 
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No projects found in this category.',
                    style: AppTypography.bodyLg.copyWith(color: AppColors.muted),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayCount,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final project = displayList[index];
                  // Find children for this project
                  final children = _filteredProjects.where((p) => p.parentId == project.id).toList();
                  return ProjectCard(
                    project: project,
                    children: children,
                  );
                },
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
                    : 'Show All ${displayList.length} Projects',
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

  Widget _buildCursusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.user.cursuses.map((cursus) {
          final isSelected = _selectedCursusId == cursus.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cursus.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCursusId = cursus.id;
                    _isExpanded = false;
                  });
                }
              },
              backgroundColor: const Color(0xFF16213E),
              selectedColor: AppColors.secondary.withValues(alpha: 0.2),
              labelStyle: AppTypography.labelCode.copyWith(
                color: isSelected ? AppColors.secondary : AppColors.muted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.secondary : Colors.transparent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_statusFilters.length, (index) {
          final isSelected = _selectedStatusIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_statusFilters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatusIndex = index;
                    _isExpanded = false;
                  });
                }
              },
              backgroundColor: const Color(0xFF16213E),
              selectedColor: AppColors.primaryRed.withValues(alpha: 0.2),
              labelStyle: AppTypography.labelCode.copyWith(
                color: isSelected ? AppColors.primaryRed : AppColors.muted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

