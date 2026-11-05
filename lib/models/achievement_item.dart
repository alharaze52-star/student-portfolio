class AchievementItem {
  final String id;
  final String title;
  final String category; // 'Хакатон', 'Олимпиада', 'Наука', 'Сертификат', 'Конференция'
  final String issuer;
  final String date;
  final String place; // '1 место', 'Победитель', 'Финалист', 'Сертификат'
  final String certificateUrl;
  final String imageUrl;
  final String description;

  AchievementItem({
    required this.id,
    required this.title,
    required this.category,
    required this.issuer,
    required this.date,
    this.place = 'Победитель',
    this.certificateUrl = '',
    this.imageUrl = '',
    this.description = '',
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Сертификат',
      issuer: json['issuer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      place: json['place']?.toString() ?? 'Победитель',
      certificateUrl: json['certificateUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'issuer': issuer,
      'date': date,
      'place': place,
      'certificateUrl': certificateUrl,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  AchievementItem copyWith({
    String? id,
    String? title,
    String? category,
    String? issuer,
    String? date,
    String? place,
    String? certificateUrl,
    String? imageUrl,
    String? description,
  }) {
    return AchievementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      issuer: issuer ?? this.issuer,
      date: date ?? this.date,
      place: place ?? this.place,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}
