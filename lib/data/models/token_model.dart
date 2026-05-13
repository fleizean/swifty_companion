class TokenModel {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final int createdAt;

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.createdAt,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int,
        createdAt: json['created_at'] as int,
      );

  bool get isExpired {
    final expiryMs = (createdAt + expiresIn) * 1000;
    return DateTime.now().millisecondsSinceEpoch >= expiryMs;
  }

  bool get canRefresh => refreshToken != null;

  Map<String, String> toStorage() => {
        'access_token': accessToken,
        'refresh_token': ?refreshToken,
        'expires_in': expiresIn.toString(),
        'created_at': createdAt.toString(),
      };

  factory TokenModel.fromStorage(Map<String, String> map) => TokenModel(
        accessToken: map['access_token']!,
        refreshToken: map['refresh_token'],
        expiresIn: int.parse(map['expires_in']!),
        createdAt: int.parse(map['created_at']!),
      );
}
