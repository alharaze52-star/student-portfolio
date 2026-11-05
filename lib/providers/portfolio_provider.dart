import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/student_profile.dart';
import '../models/project_item.dart';
import '../models/achievement_item.dart';
import '../models/skill_item.dart';
import '../services/api_service.dart';
import '../services/http_api_service.dart';
import '../services/firebase_rest_service.dart';
import '../services/local_cache_service.dart';

class PortfolioProvider extends ChangeNotifier {
  late ApiService _currentApi;
  ApiMode _mode = ApiConfig.currentMode;

  final HttpApiService _httpApi = HttpApiService();
  final FirebaseRestService _firebaseApi = FirebaseRestService();
  final LocalCacheService _localCache = LocalCacheService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  StudentProfile _profile = StudentProfile.empty();
  List<ProjectItem> _projects = [];
  List<AchievementItem> _achievements = [];
  List<SkillItem> _skills = [];

  // Фильтры и поиск
  String _projectSearchQuery = '';
  String _projectStatusFilter = 'Все';
  String _achievementCategoryFilter = 'Все';

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  ApiMode get mode => _mode;

  StudentProfile get profile => _profile;
  List<ProjectItem> get projects => _filteredProjects();
  List<ProjectItem> get allProjects => _projects;
  List<AchievementItem> get achievements => _filteredAchievements();
  List<AchievementItem> get allAchievements => _achievements;
  List<SkillItem> get skills => _skills;

  String get projectSearchQuery => _projectSearchQuery;
  String get projectStatusFilter => _projectStatusFilter;
  String get achievementCategoryFilter => _achievementCategoryFilter;

  // Статистика
  int get totalProjectsCount => _projects.length;
  int get completedProjectsCount => _projects.where((p) => p.status == 'Завершен').length;
  int get inProgressProjectsCount => _projects.where((p) => p.status == 'В разработке').length;
  int get totalAchievementsCount => _achievements.length;
  int get totalSkillsCount => _skills.length;

  PortfolioProvider() {
    _initApi();
    loadAllData();
  }

  void _initApi() {
    switch (_mode) {
      case ApiMode.backendRest:
        _currentApi = _httpApi;
        break;
      case ApiMode.firebaseDirect:
        _currentApi = _firebaseApi;
        break;
      case ApiMode.offlineMock:
        _currentApi = _localCache;
        break;
    }
  }

  void setApiMode(ApiMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    ApiConfig.currentMode = newMode;
    _initApi();
    loadAllData();
  }

  void setCustomBaseUrl(String url) {
    ApiConfig.customBaseUrl = url;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Загрузка всех данных (GET) ---
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _currentApi.getProfile(),
        _currentApi.getProjects(),
        _currentApi.getAchievements(),
        _currentApi.getSkills(),
      ]);

      _profile = results[0] as StudentProfile;
      _projects = results[1] as List<ProjectItem>;
      _achievements = results[2] as List<AchievementItem>;
      _skills = results[3] as List<SkillItem>;
    } catch (e) {
      _errorMessage = 'Не удалось загрузить данные из API. Используются локальные данные.';
      // Fallback на локальный кэш
      _profile = await _localCache.getProfile();
      _projects = await _localCache.getProjects();
      _achievements = await _localCache.getAchievements();
      _skills = await _localCache.getSkills();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Профиль (UPDATE) ---
  Future<bool> updateProfile(StudentProfile updated) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _currentApi.updateProfile(updated);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка сохранения профиля: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- Проекты (CRUD) ---
  Future<bool> createProject(ProjectItem project) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _currentApi.createProject(project);
      _projects.insert(0, created);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка добавления проекта: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(ProjectItem project) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _currentApi.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = updated;
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка обновления проекта: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _currentApi.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка удаления проекта: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- Достижения (CRUD) ---
  Future<bool> createAchievement(AchievementItem item) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _currentApi.createAchievement(item);
      _achievements.insert(0, created);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка добавления достижения: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAchievement(AchievementItem item) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _currentApi.updateAchievement(item);
      final index = _achievements.indexWhere((a) => a.id == item.id);
      if (index != -1) {
        _achievements[index] = updated;
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка обновления достижения: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAchievement(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _currentApi.deleteAchievement(id);
      _achievements.removeWhere((a) => a.id == id);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка удаления достижения: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- Навыки (CRUD) ---
  Future<bool> createSkill(SkillItem item) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _currentApi.createSkill(item);
      _skills.add(created);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка добавления навыка: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSkill(SkillItem item) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _currentApi.updateSkill(item);
      final index = _skills.indexWhere((s) => s.id == item.id);
      if (index != -1) {
        _skills[index] = updated;
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка обновления навыка: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _currentApi.deleteSkill(id);
      _skills.removeWhere((s) => s.id == id);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка удаления навыка: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- Фильтрация ---
  void setProjectSearchQuery(String query) {
    _projectSearchQuery = query;
    notifyListeners();
  }

  void setProjectStatusFilter(String status) {
    _projectStatusFilter = status;
    notifyListeners();
  }

  void setAchievementCategoryFilter(String category) {
    _achievementCategoryFilter = category;
    notifyListeners();
  }

  List<ProjectItem> _filteredProjects() {
    return _projects.where((p) {
      final matchesQuery = _projectSearchQuery.isEmpty ||
          p.title.toLowerCase().contains(_projectSearchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_projectSearchQuery.toLowerCase()) ||
          p.tags.any((tag) => tag.toLowerCase().contains(_projectSearchQuery.toLowerCase()));

      final matchesStatus = _projectStatusFilter == 'Все' || p.status == _projectStatusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<AchievementItem> _filteredAchievements() {
    return _achievements.where((a) {
      if (_achievementCategoryFilter == 'Все') return true;
      return a.category == _achievementCategoryFilter;
    }).toList();
  }
}

