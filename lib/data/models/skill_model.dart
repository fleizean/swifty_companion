class SkillModel {
  final String name;
  final double level;

  const SkillModel({required this.name, required this.level});

  double get percentage => (level % 1) * 100;

  factory SkillModel.fromJson(Map<String, dynamic> json) => SkillModel(
        name: json['name'] as String,
        level: (json['level'] as num).toDouble(),
      );
}
