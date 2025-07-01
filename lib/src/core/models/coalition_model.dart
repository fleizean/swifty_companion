import 'package:peer42/src/core/models/coalition_user_model.dart';

class CoalitionModel {
  CoalitionModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.score,
    required this.slug,
    this.coverUrl,
    this.users,
  });

  factory CoalitionModel.fromJson(Map<String, dynamic> json) {
    try {      
      List<CoalitionUserModel> usersList = [];
      if (json['users'] != null && json['users'] is List) {
        
        for (var userData in json['users'] as List) {
          try {
            usersList.add(CoalitionUserModel.fromJson(userData as Map<String, dynamic>));
          } catch (e) {
            
          }
        }
      }

      final result = CoalitionModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        color: json['color']?.toString() ?? '#000000',
        coverUrl: json['cover_url']?.toString(),
        score: (json['score'] as num?)?.toInt() ?? 0,
        slug: json['slug']?.toString() ?? '',
        users: usersList,
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  final int id;
  final String name;
  final String imageUrl;
  final String color;
  final String? coverUrl;
  final int score;
  final String slug;
  final List<CoalitionUserModel>? users;

  int get colorValue => int.parse('0xFF${color.replaceAll('#', '')}');
}
