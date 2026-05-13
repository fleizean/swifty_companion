import 'skill_model.dart';
import 'project_model.dart';
import 'cursus_model.dart';

class UserModel {
  final int id;
  final String login;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? location;
  final int wallet;
  final int correctionPoints;
  final String? blackholedAt;
  final double level;
  final List<SkillModel> skills;
  final List<ProjectModel> projects;
  final String? campus;
  final String? displayName;
  final List<CursusModel> cursuses;

  const UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.location,
    required this.wallet,
    required this.correctionPoints,
    required this.blackholedAt,
    required this.level,
    required this.skills,
    required this.projects,
    required this.campus,
    required this.displayName,
    required this.cursuses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final cursusUsers = json['cursus_users'] as List<dynamic>? ?? [];
    final mainCursus = cursusUsers.cast<Map<String, dynamic>>().firstWhere(
          (cu) => (cu['cursus'] as Map<String, dynamic>)['slug'] == '42cursus',
          orElse: () => cursusUsers.isNotEmpty
              ? cursusUsers.last as Map<String, dynamic>
              : <String, dynamic>{},
        );

    final level = (mainCursus['level'] as num?)?.toDouble() ?? 0.0;
    final rawSkills = mainCursus['skills'] as List<dynamic>? ?? [];
    final skills = rawSkills
        .cast<Map<String, dynamic>>()
        .map(SkillModel.fromJson)
        .toList()
      ..sort((a, b) => b.level.compareTo(a.level));

    final rawProjects = json['projects_users'] as List<dynamic>? ?? [];
    final projects = rawProjects
        .cast<Map<String, dynamic>>()
        // We include all projects now, as we want to show hierarchical parent projects too
        .map(ProjectModel.fromJson)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final cursuses = cursusUsers
        .map((cu) => CursusModel.fromJson(cu['cursus'] as Map<String, dynamic>))
        .toList();

    final campusList = json['campus'] as List<dynamic>? ?? [];
    final campusName = campusList.isNotEmpty
        ? (campusList.first as Map<String, dynamic>)['name'] as String?
        : null;

    final image = json['image'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as int,
      login: json['login'] as String,
      email: json['email'] as String?,
      phone: _sanitizePhone(json['phone'] as String?),
      imageUrl: image?['link'] as String?,
      location: json['location'] as String?,
      wallet: json['wallet'] as int? ?? 0,
      correctionPoints: json['correction_point'] as int? ?? 0,
      blackholedAt: mainCursus['blackholed_at'] as String?,
      level: level,
      skills: skills,
      projects: projects,
      campus: campusName,
      displayName: json['displayname'] as String?,
      cursuses: cursuses,
    );
  }

  static String? _sanitizePhone(String? phone) {
    if (phone == null || phone == 'hidden' || phone.isEmpty) return null;
    return phone;
  }

  int get levelInt => level.floor();
  double get levelProgress => level % 1;
}
