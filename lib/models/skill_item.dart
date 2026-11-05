class SkillItem {
  final String id;
  final String name;
  final String category; // 'Hard Skills', 'Soft Skills', 'Языки', 'Инструменты'
  final double level; // 0.0 .. 1.0
  final String levelTitle; // 'Базовый', 'Средний', 'Продвинутый', 'Эксперт', 'B2 / Upper-Intermediate'

  SkillItem({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.levelTitle,
  });

  factory SkillItem.fromJson(Map<String, dynamic> json) {
    return SkillItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Hard Skills',
      level: (json['level'] is num)
          ? (json['level'] as num).toDouble()
          : double.tryParse(json['level']?.toString() ?? '0.5') ?? 0.5,
      levelTitle: json['levelTitle']?.toString() ?? 'Средний',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'level': level,
      'levelTitle': levelTitle,
    };
  }

  SkillItem copyWith({
    String? id,
    String? name,
    String? category,
    double? level,
    String? levelTitle,
  }) {
    return SkillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
    );
  }
}

