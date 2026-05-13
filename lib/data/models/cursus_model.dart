class CursusModel {
  final int id;
  final String name;
  final String slug;

  const CursusModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CursusModel.fromJson(Map<String, dynamic> json) {
    return CursusModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}
