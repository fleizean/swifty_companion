enum ProjectStatus { finished, inProgress, failed, searchingGroup, parent, unknown }

class ProjectModel {
  final int id;
  final String name;
  final ProjectStatus status;
  final int? finalMark;
  final bool validated;
  final int? parentId;
  final List<int> cursusIds;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.status,
    required this.finalMark,
    required this.validated,
    required this.parentId,
    required this.cursusIds,
  });

  bool get isFailed => status == ProjectStatus.finished && !validated;

  int get sortOrder {
    if (status == ProjectStatus.inProgress) return 0;
    if (status == ProjectStatus.finished && validated) return 1;
    if (status == ProjectStatus.finished && !validated) return 2;
    return 3; // searchingGroup, unknown, or parent
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? '';
    final status = switch (rawStatus) {
      'finished' => ProjectStatus.finished,
      'in_progress' => ProjectStatus.inProgress,
      'searching_a_group' => ProjectStatus.searchingGroup,
      'parent' => ProjectStatus.parent,
      _ => ProjectStatus.unknown,
    };

    final projectInfo = json['project'] as Map<String, dynamic>;

    return ProjectModel(
      id: projectInfo['id'] as int,
      name: projectInfo['name'] as String,
      status: status,
      finalMark: json['final_mark'] as int?,
      validated: json['validated?'] as bool? ?? false,
      parentId: projectInfo['parent_id'] as int?,
      cursusIds: (json['cursus_ids'] as List<dynamic>? ?? [])
          .map((id) => id as int)
          .toList(),
    );
  }
}
