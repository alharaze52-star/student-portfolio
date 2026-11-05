class StudentProfile {
  final String id;
  final String fullName;
  final String title;
  final String university;
  final String faculty;
  final String group;
  final double gpa;
  final String email;
  final String phone;
  final String githubUrl;
  final String telegramUrl;
  final String bio;
  final String avatarUrl;
  final DateTime updatedAt;

  StudentProfile({
    required this.id,
    required this.fullName,
    required this.title,
    required this.university,
    required this.faculty,
    required this.group,
    required this.gpa,
    required this.email,
    required this.phone,
    required this.githubUrl,
    required this.telegramUrl,
    required this.bio,
    required this.avatarUrl,
    required this.updatedAt,
  });

  factory StudentProfile.empty() {
    return StudentProfile(
      id: 'default_student',
      fullName: 'Иванов Иван Иванович',
      title: 'Студент кафедры ИСТ, Flutter-разработчик',
      university: 'Технический Университет',
      faculty: 'Информационные технологии и программирование',
      group: 'ПИ-301',
      gpa: 4.85,
      email: 'student.ivanov@edu.university.ru',
      phone: '+7 (999) 123-45-67',
      githubUrl: 'https://github.com/student-portfolio',
      telegramUrl: '@ivanov_dev',
      bio: 'Увлеченный мобильный разработчик с опытом создания кроссплатформенных приложений на Flutter и Dart. Интересуюсь чистой архитектурой, современным UI/UX и интеграцией с облачными API.',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      updatedAt: DateTime.now(),
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString() ?? 'default_student',
      fullName: json['fullName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      faculty: json['faculty']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      gpa: (json['gpa'] is num) ? (json['gpa'] as num).toDouble() : double.tryParse(json['gpa']?.toString() ?? '0.0') ?? 0.0,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      githubUrl: json['githubUrl']?.toString() ?? '',
      telegramUrl: json['telegramUrl']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      updatedAt: json['updatedAt'] != null 
          ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'title': title,
      'university': university,
      'faculty': faculty,
      'group': group,
      'gpa': gpa,
      'email': email,
      'phone': phone,
      'githubUrl': githubUrl,
      'telegramUrl': telegramUrl,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StudentProfile copyWith({
    String? id,
    String? fullName,
    String? title,
    String? university,
    String? faculty,
    String? group,
    double? gpa,
    String? email,
    String? phone,
    String? githubUrl,
    String? telegramUrl,
    String? bio,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      group: group ?? this.group,
      gpa: gpa ?? this.gpa,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      githubUrl: githubUrl ?? this.githubUrl,
      telegramUrl: telegramUrl ?? this.telegramUrl,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
