class CoalitionModel {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final String color;
  final int score;

  const CoalitionModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.color,
    required this.score,
  });

  factory CoalitionModel.fromJson(Map<String, dynamic> json) => CoalitionModel(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        imageUrl: json['image_url'] as String?,
        color: json['color'] as String? ?? '#EA4B40',
        score: json['score'] as int? ?? 0,
      );
}
