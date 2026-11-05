class ProjectItem {
  final String id;
  final String title;
  final String description;
  final String role;
  final String status; // 'Завершен', 'В разработке', 'Планируется'
  final List<String> tags;
  final String githubUrl;
  final String demoUrl;
  final String imageUrl;
  final String period;
  final bool isFeatured;
  final DateTime createdAt;

  ProjectItem({
    required this.id,
    required this.title,
    required this.description,
    required this.role,
    this.status = 'Завершен',
    required this.tags,
    this.githubUrl = '',
    this.demoUrl = '',
    this.imageUrl = '',
    required this.period,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
    } else if (json['tags'] is String && json['tags'].toString().isNotEmpty) {
      parsedTags = json['tags'].toString().split(',').map((e) => e.trim()).toList();
    }

    return ProjectItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Разработчик',
      status: json['status']?.toString() ?? 'Завершен',
      tags: parsedTags,
      githubUrl: json['githubUrl']?.toString() ?? '',
      demoUrl: json['demoUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true || json['isFeatured']?.toString() == 'true',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'role': role,
      'status': status,
      'tags': tags,
      'githubUrl': githubUrl,
      'demoUrl': demoUrl,
      'imageUrl': imageUrl,
      'period': period,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProjectItem copyWith({
    String? id,
    String? title,
    String? description,
    String? role,
    String? status,
    List<String>? tags,
    String? githubUrl,
    String? demoUrl,
    String? imageUrl,
    String? period,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      role: role ?? this.role,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      githubUrl: githubUrl ?? this.githubUrl,
      demoUrl: demoUrl ?? this.demoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      period: period ?? this.period,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

