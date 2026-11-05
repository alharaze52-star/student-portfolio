import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_profile.dart';
import '../models/project_item.dart';
import '../models/achievement_item.dart';
import '../models/skill_item.dart';
import 'api_service.dart';

class LocalCacheService implements ApiService {
  static const String _keyProfile = 'cache_student_profile';
  static const String _keyProjects = 'cache_projects';
  static const String _keyAchievements = 'cache_achievements';
  static const String _keySkills = 'cache_skills';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> seedInitialDataIfEmpty() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_keyProfile)) {
      final defaultProfile = StudentProfile.empty();
      await prefs.setString(_keyProfile, jsonEncode(defaultProfile.toJson()));
    }

    if (!prefs.containsKey(_keyProjects)) {
      final initialProjects = [
        ProjectItem(
          id: 'proj_1',
          title: 'Мобильное приложение "Цифровое портфолио"',
          description: 'Кроссплатформенное приложение на Flutter и Dart для учета учебных, научных и проектных достижений студента. Включает интеграцию с Firebase API и бэкендом.',
          role: 'Lead Flutter Developer',
          status: 'Завершен',
          tags: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Provider'],
          githubUrl: 'https://github.com/student/digital-portfolio-flutter',
          demoUrl: 'https://portfolio-demo.app',
          imageUrl: 'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800',
          period: 'Октябрь 2024 - Ноябрь 2024',
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ProjectItem(
          id: 'proj_2',
          title: 'Сервис расписания занятий университета',
          description: 'Мобильный клиент и API-шлюз для парсинга и отображения расписания пар, аудиторий и уведомлений о заменах в реальном времени.',
          role: 'Backend & Mobile Dev',
          status: 'Завершен',
          tags: ['Node.js', 'Express', 'Flutter', 'SQLite', 'Push Notifications'],
          githubUrl: 'https://github.com/student/schedule-helper',
          imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800',
          period: 'Март 2024 - Май 2024',
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
        ProjectItem(
          id: 'proj_3',
          title: 'Telegram-бот для автоматизации сдачи ДЗ',
          description: 'Бот для старост и преподавателей: прием лабораторных работ, проверка формата архивов, учет баллов в Google Таблицах.',
          role: 'Python Developer',
          status: 'Завершен',
          tags: ['Python', 'Aiogram', 'PostgreSQL', 'Docker'],
          githubUrl: 'https://github.com/student/hw-tracker-bot',
          imageUrl: 'https://images.unsplash.com/photo-1618401471353-b98aedd04e11?w=800',
          period: 'Сентябрь 2023 - Декабрь 2023',
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
        ),
        ProjectItem(
          id: 'proj_4',
          title: 'AI Ассистент конспектирования лекций',
          description: 'Мобильное приложение для распознавания аудиозаписей лекций и автоматического создания краткого конспекта (суммаризации) через LLM.',
          role: 'Fullstack Dev & ML Researcher',
          status: 'В разработке',
          tags: ['Flutter', 'Gemini API', 'FastAPI', 'Whisper'],
          imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
          period: 'Сентябрь 2024 - настоящее время',
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
      await prefs.setString(_keyProjects, jsonEncode(initialProjects.map((e) => e.toJson()).toList()));
    }

    if (!prefs.containsKey(_keyAchievements)) {
      final initialAchievements = [
        AchievementItem(
          id: 'ach_1',
          title: 'Победитель регионального хакатона "Цифровой прорыв"',
          category: 'Хакатон',
          issuer: 'АНО "Россия - страна возможностей"',
          date: 'Октябрь 2024',
          place: '1 место',
          description: 'Разработка прототипа мобильного сервиса для студентов за 48 часов в треке "Образование".',
          imageUrl: 'https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=800',
        ),
        AchievementItem(
          id: 'ach_2',
          title: 'Диплом I степени Всероссийской студенческой олимпиады по программированию',
          category: 'Олимпиада',
          issuer: 'Минобрнауки РФ',
          date: 'Апрель 2024',
          place: 'Победитель',
          description: 'Решение алгоритмических задач повышенной сложности и оптимизация структур данных.',
          imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800',
        ),
        AchievementItem(
          id: 'ach_3',
          title: 'Сертификат Google Flutter & Dart Certified Specialist',
          category: 'Сертификат',
          issuer: 'Google Developers / Coursera',
          date: 'Июнь 2024',
          place: 'Сертификат с отличием',
          description: 'Успешное прохождение курса по продвинутой разработке кроссплатформенных приложений на Flutter.',
        ),
        AchievementItem(
          id: 'ach_4',
          title: 'Публикация статьи в сборнике РИНЦ',
          category: 'Наука',
          issuer: 'Международная конференция молодых ученых',
          date: 'Май 2024',
          place: 'Автор',
          description: 'Тема: "Применение компонентного подхода и реактивного управления состоянием в мобильных приложениях".',
        ),
      ];
      await prefs.setString(_keyAchievements, jsonEncode(initialAchievements.map((e) => e.toJson()).toList()));
    }

    if (!prefs.containsKey(_keySkills)) {
      final initialSkills = [
        SkillItem(id: 'sk_1', name: 'Flutter & Dart', category: 'Hard Skills', level: 0.90, levelTitle: 'Продвинутый'),
        SkillItem(id: 'sk_2', name: 'REST API & JSON', category: 'Hard Skills', level: 0.95, levelTitle: 'Эксперт'),
        SkillItem(id: 'sk_3', name: 'Firebase (Firestore, Auth)', category: 'Hard Skills', level: 0.85, levelTitle: 'Продвинутый'),
        SkillItem(id: 'sk_4', name: 'State Management (Provider/Bloc)', category: 'Hard Skills', level: 0.88, levelTitle: 'Продвинутый'),
        SkillItem(id: 'sk_5', name: 'Git & GitHub Actions (CI/CD)', category: 'Инструменты', level: 0.82, levelTitle: 'Уверенный'),
        SkillItem(id: 'sk_6', name: 'Figma UI/UX прототипирование', category: 'Инструменты', level: 0.80, levelTitle: 'Уверенный'),
        SkillItem(id: 'sk_7', name: 'Командная работа & Agile/Scrum', category: 'Soft Skills', level: 0.92, levelTitle: 'Высокий'),
        SkillItem(id: 'sk_8', name: 'Английский язык (Technical English)', category: 'Языки', level: 0.80, levelTitle: 'B2 / Upper-Intermediate'),
      ];
      await prefs.setString(_keySkills, jsonEncode(initialSkills.map((e) => e.toJson()).toList()));
    }
  }

  // --- Профиль ---
  @override
  Future<StudentProfile> getProfile() async {
    await seedInitialDataIfEmpty();
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      return StudentProfile.fromJson(jsonDecode(jsonStr));
    }
    return StudentProfile.empty();
  }

  @override
  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    final prefs = await _prefs;
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await prefs.setString(_keyProfile, jsonEncode(updated.toJson()));
    return updated;
  }

  // --- Проекты ---
  @override
  Future<List<ProjectItem>> getProjects() async {
    await seedInitialDataIfEmpty();
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyProjects);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final List raw = jsonDecode(jsonStr);
      return raw.map((e) => ProjectItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ProjectItem> createProject(ProjectItem project) async {
    final list = await getProjects();
    final itemToSave = project.copyWith(
      id: project.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : project.id,
      createdAt: DateTime.now(),
    );
    list.insert(0, itemToSave);
    final prefs = await _prefs;
    await prefs.setString(_keyProjects, jsonEncode(list.map((e) => e.toJson()).toList()));
    return itemToSave;
  }

  @override
  Future<ProjectItem> updateProject(ProjectItem project) async {
    final list = await getProjects();
    final index = list.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      list[index] = project;
      final prefs = await _prefs;
      await prefs.setString(_keyProjects, jsonEncode(list.map((e) => e.toJson()).toList()));
      return project;
    }
    return createProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    final list = await getProjects();
    list.removeWhere((p) => p.id == id);
    final prefs = await _prefs;
    await prefs.setString(_keyProjects, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // --- Достижения ---
  @override
  Future<List<AchievementItem>> getAchievements() async {
    await seedInitialDataIfEmpty();
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyAchievements);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final List raw = jsonDecode(jsonStr);
      return raw.map((e) => AchievementItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<AchievementItem> createAchievement(AchievementItem item) async {
    final list = await getAchievements();
    final itemToSave = item.copyWith(
      id: item.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : item.id,
    );
    list.insert(0, itemToSave);
    final prefs = await _prefs;
    await prefs.setString(_keyAchievements, jsonEncode(list.map((e) => e.toJson()).toList()));
    return itemToSave;
  }

  @override
  Future<AchievementItem> updateAchievement(AchievementItem item) async {
    final list = await getAchievements();
    final index = list.indexWhere((a) => a.id == item.id);
    if (index != -1) {
      list[index] = item;
      final prefs = await _prefs;
      await prefs.setString(_keyAchievements, jsonEncode(list.map((e) => e.toJson()).toList()));
      return item;
    }
    return createAchievement(item);
  }

  @override
  Future<void> deleteAchievement(String id) async {
    final list = await getAchievements();
    list.removeWhere((a) => a.id == id);
    final prefs = await _prefs;
    await prefs.setString(_keyAchievements, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // --- Навыки ---
  @override
  Future<List<SkillItem>> getSkills() async {
    await seedInitialDataIfEmpty();
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keySkills);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final List raw = jsonDecode(jsonStr);
      return raw.map((e) => SkillItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SkillItem> createSkill(SkillItem item) async {
    final list = await getSkills();
    final itemToSave = item.copyWith(
      id: item.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : item.id,
    );
    list.add(itemToSave);
    final prefs = await _prefs;
    await prefs.setString(_keySkills, jsonEncode(list.map((e) => e.toJson()).toList()));
    return itemToSave;
  }

  @override
  Future<SkillItem> updateSkill(SkillItem item) async {
    final list = await getSkills();
    final index = list.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      list[index] = item;
      final prefs = await _prefs;
      await prefs.setString(_keySkills, jsonEncode(list.map((e) => e.toJson()).toList()));
      return item;
    }
    return createSkill(item);
  }

  @override
  Future<void> deleteSkill(String id) async {
    final list = await getSkills();
    list.removeWhere((s) => s.id == id);
    final prefs = await _prefs;
    await prefs.setString(_keySkills, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
