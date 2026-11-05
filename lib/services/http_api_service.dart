import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/student_profile.dart';
import '../models/project_item.dart';
import '../models/achievement_item.dart';
import '../models/skill_item.dart';
import 'api_service.dart';
import 'local_cache_service.dart';

class HttpApiService implements ApiService {
  final LocalCacheService _cache = LocalCacheService();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // Helper для безопасного парсинга ответов
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Ошибка API (${response.statusCode}): ${response.reasonPhrase}');
    }
  }

  // --- Профиль ---
  @override
  Future<StudentProfile> getProfile() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/profile');
      final res = await http.get(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final profile = StudentProfile.fromJson(data);
      await _cache.updateProfile(profile);
      return profile;
    } catch (e) {
      // При ошибке сети отдаем локальный кэш
      return await _cache.getProfile();
    }
  }

  @override
  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/profile');
      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(profile.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final updated = StudentProfile.fromJson(data);
      await _cache.updateProfile(updated);
      return updated;
    } catch (e) {
      // Обновляем в локальном кэше
      return await _cache.updateProfile(profile);
    }
  }

  // --- Проекты ---
  @override
  Future<List<ProjectItem>> getProjects() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/projects');
      final res = await http.get(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res) as List;
      final projects = data.map((e) => ProjectItem.fromJson(e)).toList();
      return projects;
    } catch (e) {
      return await _cache.getProjects();
    }
  }

  @override
  Future<ProjectItem> createProject(ProjectItem project) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/projects');
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(project.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final created = ProjectItem.fromJson(data);
      await _cache.createProject(created);
      return created;
    } catch (e) {
      return await _cache.createProject(project);
    }
  }

  @override
  Future<ProjectItem> updateProject(ProjectItem project) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/projects/${project.id}');
      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(project.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final updated = ProjectItem.fromJson(data);
      await _cache.updateProject(updated);
      return updated;
    } catch (e) {
      return await _cache.updateProject(project);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/projects/$id');
      final res = await http.delete(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      _processResponse(res);
    } catch (_) {
      // Игнорируем сетевые сбои, удаляя локально
    } finally {
      await _cache.deleteProject(id);
    }
  }

  // --- Достижения ---
  @override
  Future<List<AchievementItem>> getAchievements() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/achievements');
      final res = await http.get(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res) as List;
      return data.map((e) => AchievementItem.fromJson(e)).toList();
    } catch (e) {
      return await _cache.getAchievements();
    }
  }

  @override
  Future<AchievementItem> createAchievement(AchievementItem item) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/achievements');
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(item.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final created = AchievementItem.fromJson(data);
      await _cache.createAchievement(created);
      return created;
    } catch (e) {
      return await _cache.createAchievement(item);
    }
  }

  @override
  Future<AchievementItem> updateAchievement(AchievementItem item) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/achievements/${item.id}');
      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(item.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final updated = AchievementItem.fromJson(data);
      await _cache.updateAchievement(updated);
      return updated;
    } catch (e) {
      return await _cache.updateAchievement(item);
    }
  }

  @override
  Future<void> deleteAchievement(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/achievements/$id');
      final res = await http.delete(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      _processResponse(res);
    } catch (_) {
    } finally {
      await _cache.deleteAchievement(id);
    }
  }

  // --- Навыки ---
  @override
  Future<List<SkillItem>> getSkills() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/skills');
      final res = await http.get(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res) as List;
      return data.map((e) => SkillItem.fromJson(e)).toList();
    } catch (e) {
      return await _cache.getSkills();
    }
  }

  @override
  Future<SkillItem> createSkill(SkillItem item) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/skills');
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(item.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final created = SkillItem.fromJson(data);
      await _cache.createSkill(created);
      return created;
    } catch (e) {
      return await _cache.createSkill(item);
    }
  }

  @override
  Future<SkillItem> updateSkill(SkillItem item) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/skills/${item.id}');
      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(item.toJson()),
      ).timeout(ApiConfig.requestTimeout);
      final data = _processResponse(res);
      final updated = SkillItem.fromJson(data);
      await _cache.updateSkill(updated);
      return updated;
    } catch (e) {
      return await _cache.updateSkill(item);
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/skills/$id');
      final res = await http.delete(url, headers: _headers).timeout(ApiConfig.requestTimeout);
      _processResponse(res);
    } catch (_) {
    } finally {
      await _cache.deleteSkill(id);
    }
  }
}

