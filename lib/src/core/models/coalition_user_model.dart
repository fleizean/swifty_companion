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
    try {      
      Map<String, dynamic>? userData;
      if (json['user'] != null) {
        userData = json['user'] as Map<String, dynamic>;
      }

      final result = CoalitionUserModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        score: (json['score'] as num?)?.toInt() ?? 0,
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        coalitionId: (json['coalition_id'] as num?)?.toInt() ?? 0,
        userId: json['user_id']?.toString() ?? '',
        user: userData,
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  final int id;
  final int score;
  final int rank;
  final int coalitionId;
  final String userId;
  final Map<String, dynamic>? user;

  String get userLogin => user?['login']?.toString() ?? 'Unknown';
  String get userDisplayName => user?['displayname']?.toString() ?? user?['login']?.toString() ?? 'Unknown';
  String? get userImageUrl => user?['image']?['link']?.toString();
  double get userLevel => (user?['level'] as num?)?.toDouble() ?? 0.0;
}
