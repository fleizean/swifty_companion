class UserModel {
  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.correctionPoint,
    required this.wallet,
    required this.level,
    required this.skills,
    required this.achievements,
    required this.isActive,
    required this.cursusUsers,
    this.phone,
    this.imageUrl,
    this.kind,
    this.poolYear,
    this.poolMonth,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Cursus users'ı incele
    final cursusUsers = json['cursus_users'] as List<dynamic>? ?? [];

    // Eğer cursus_users boşsa skills ve achievements'i direkt json'dan al
    var skills = <dynamic>[];
    var achievements = <dynamic>[];
    double level = 0.0;

    if (cursusUsers.isNotEmpty) {
      // Cursus users'dan al
      Map<String, dynamic>? currentCursus;

      for (final cursus in cursusUsers) {
        if (cursus['cursus_id'] == 21) {
          // 21 is 42cursus
          currentCursus = cursus as Map<String, dynamic>;
          break;
        }
      }

      if (currentCursus == null && cursusUsers.isNotEmpty) {
        currentCursus = cursusUsers.first as Map<String, dynamic>;
      }

      level = currentCursus?['level'] != null
          ? (currentCursus!['level'] as num).toDouble()
          : 0.0;
      skills = currentCursus?['skills'] as List<dynamic>? ?? [];
    } else {
      // Direkt JSON'dan al
      skills = json['skills'] as List<dynamic>? ?? [];
      achievements = json['achievements'] as List<dynamic>? ?? [];
      level = (json['level'] as num?)?.toDouble() ?? 0.0;
    }

    // Skills parsing
    final finalSkillModels = <SkillModel>[];
    for (final skill in skills) {
      try {
        final skillModel = SkillModel.fromJson(skill as Map<String, dynamic>);
        finalSkillModels.add(skillModel);
      } catch (e) {
        // Skill parsing hatası
      }
    }

    // Achievements parsing
    final finalAchievementModels = <AchievementModel>[];
    for (final achievement in achievements) {
      try {
        final achievementModel =
            AchievementModel.fromJson(achievement as Map<String, dynamic>);
        finalAchievementModels.add(achievementModel);
      } catch (e) {
        // Achievement parsing hatası
      }
    }

    // Parse cursus users
    final cursusUsersList = cursusUsers
        .map((cursusData) =>
            CursusUser.fromJson(cursusData as Map<String, dynamic>))
        .toList();

    return UserModel(
      id: json['id'] as int? ?? 0,
      login: json['login']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      displayName:
          json['displayname']?.toString() ?? json['login']?.toString() ?? '',
      phone: json['phone'] as String?,
      imageUrl: json['image']?['link'] as String?,
      correctionPoint: json['correction_point'] as int? ?? 0,
      wallet: json['wallet'] as int? ?? 0,
      poolYear: json['pool_year'] as String?,
      poolMonth: json['pool_month'] as String?,
      level: level,
      skills: finalSkillModels,
      kind: json['kind'] as String? ?? 'student', // Default to 'student'
      achievements: finalAchievementModels,
      location: json['location'] as String?,
      isActive: json['active?'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      cursusUsers: cursusUsersList,
    );
  }

  final int id; // Assuming id is always present, otherwise make it nullable
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? phone;
  final String? imageUrl;
  final int correctionPoint;
  final int wallet;
  final String? poolYear;
  final String? poolMonth;
  final String? kind; // Default to 'student' if not present
  final double level;
  final List<SkillModel> skills;
  final List<AchievementModel> achievements;
  final String? location;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CursusUser> cursusUsers;

  String get fullName => '$firstName $lastName';

  double get levelProgress => level - level.floor();

  String get levelDisplay =>
      'Level ${level.floor()} - ${(levelProgress * 100).toStringAsFixed(0)}%';
}

class CursusUser {
  CursusUser({
    required this.id,
    this.grade,
    required this.level,
    required this.cursusId,
    this.cursus,
    this.beginAt,
    this.endAt,
    this.userId,
    this.user,
  });

  factory CursusUser.fromJson(Map<String, dynamic> json) {
    // Extract user data if available
    final userData = json['user'] as Map<String, dynamic>?;

    return CursusUser(
      id: json['id'] as int? ?? 0,
      grade: json['grade'] as String?,
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
      cursusId: json['cursus_id'] as int? ?? 0,
      beginAt: json['begin_at'] != null
          ? DateTime.parse(json['begin_at'].toString())
          : null,
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'].toString())
          : null,
      cursus: json['cursus'] != null
          ? Cursus.fromJson(json['cursus'] as Map<String, dynamic>)
          : null,
      userId: userData?['id'] as int?,
      user: userData,
    );
  }

  final int id;
  final String? grade;
  final double level;
  final int cursusId;
  final DateTime? beginAt;
  final DateTime? endAt;
  final Cursus? cursus;
  final int? userId;
  final Map<String, dynamic>? user;
}

class Cursus {
  Cursus({
    required this.id,
    required this.name,
    required this.slug,
    required this.kind,
  });

  factory Cursus.fromJson(Map<String, dynamic> json) {
    return Cursus(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String slug;
  final String kind;
}

class SkillModel {
  SkillModel({
    required this.name,
    required this.level,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name']?.toString() ?? '',
      level: json['level'] != null
          ? (json['level'] is double
              ? json['level'] as double
              : (json['level'] as num).toDouble())
          : 0.0,
    );
  }
  final String name;
  final double level;
}

class AchievementModel {
  AchievementModel({
    required this.name,
    required this.description,
    required this.kind,
    required this.tier,
    this.imageUrl,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      tier: json['tier']?.toString() ?? '',
      imageUrl: json['image'] as String?,
    );
  }
  final String name;
  final String description;
  final String kind;
  final String tier;
  final String? imageUrl;
}
