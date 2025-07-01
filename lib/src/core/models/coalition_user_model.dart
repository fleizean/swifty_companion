class CoalitionUserModel {
  CoalitionUserModel({
    required this.id,
    required this.score,
    required this.rank,
    required this.coalitionId,
    required this.userId,
    this.user,
  });

  factory CoalitionUserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userData;
    if (json['user'] != null) {
      userData = json['user'] as Map<String, dynamic>;
    }

    return CoalitionUserModel(
      id: json['id'] as int,
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      coalitionId: json['coalition_id'] as int,
      userId: json['user_id'] as String,
      user: userData,
    );
  }

  final int id;
  final int score;
  final int rank;
  final int coalitionId;
  final String userId;
  final Map<String, dynamic>? user;

    String get userLogin => user?['login'] ?? 'Unknown';
    String get userDisplayName => user?['displayname'] ?? user?['login'] ?? 'Unknown';
    String? get userImageUrl => user?['image']?['link'];
    double get userLevel => (user?['level'] as num?)?.toDouble() ?? 0.0;
}
