import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/student_profile.dart';
import '../models/project_item.dart';
import '../models/achievement_item.dart';
import '../models/skill_item.dart';
import 'api_service.dart';
import 'local_cache_service.dart';

/// Сервис прямого взаимодействия с базой данных Google Firebase Cloud Firestore
/// через официальный REST API без тяжелых нативных SDK:
/// https://firebase.google.com/docs/firestore/reference/rest
class FirebaseRestService implements ApiService {
  final LocalCacheService _cache = LocalCacheService();

  String get _endpoint => ApiConfig.firebaseRestEndpoint;

  // Конвертация Flutter Map в формат Firestore Document Fields
  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    data.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is double) {
        fields[key] = {'doubleValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': value.toString()};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is List) {
        fields[key] = {
          'arrayValue': {
            'values': value.map((v) => {'stringValue': v.toString()}).toList()
          }
        };
      }
    });
    return {'fields': fields};
  }

  // Конвертация формата Firestore Document обратно в Dart Map
  Map<String, dynamic> _fromFirestoreDocument(Map<String, dynamic> doc) {
    final Map<String, dynamic> result = {};
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    fields.forEach((key, val) {
      if (val is Map) {
        if (val.containsKey('stringValue')) {
          result[key] = val['stringValue'];
        } else if (val.containsKey('doubleValue')) {
          result[key] = (val['doubleValue'] as num).toDouble();
        } else if (val.containsKey('integerValue')) {
          result[key] = int.tryParse(val['integerValue'].toString()) ?? 0;
        } else if (val.containsKey('booleanValue')) {
          result[key] = val['booleanValue'];
        } else if (val.containsKey('arrayValue')) {
          final listValues = val['arrayValue']?['values'] as List? ?? [];
          result[key] = listValues.map((item) => item['stringValue'] ?? item.toString()).toList();
        }
      }
    });
    // Извлекаем ID документа из поля name: "projects/.../documents/col/DOC_ID"
    if (doc['name'] != null && !result.containsKey('id')) {
      final parts = doc['name'].toString().split('/');
      result['id'] = parts.last;
    }
    return result;
  }

  // --- Профиль ---
  @override
  Future<StudentProfile> getProfile() async {
    try {
      final url = Uri.parse('$_endpoint/profile/main');
      final res = await http.get(url).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final doc = jsonDecode(res.body);
        final profile = StudentProfile.fromJson(_fromFirestoreDocument(doc));
        await _cache.updateProfile(profile);
        return profile;
      }
    } catch (_) {}
    return await _cache.getProfile();
  }

  @override
  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    try {
      final url = Uri.parse('$_endpoint/profile/main');
      final body = jsonEncode(_toFirestoreFields(profile.toJson()));
      final res = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await _cache.updateProfile(profile);
        return profile;
      }
    } catch (_) {}
    return await _cache.updateProfile(profile);
  }

  // --- Проекты ---
  @override
  Future<List<ProjectItem>> getProjects() async {
    try {
      final url = Uri.parse('$_endpoint/projects');
      final res = await http.get(url).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List docs = data['documents'] ?? [];
        final projects = docs.map((d) => ProjectItem.fromJson(_fromFirestoreDocument(d))).toList();
        return projects;
      }
    } catch (_) {}
    return await _cache.getProjects();
  }

  @override
  Future<ProjectItem> createProject(ProjectItem project) async {
    try {
      final docId = project.id.isNotEmpty ? project.id : DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse('$_endpoint/projects?documentId=$docId');
      final body = jsonEncode(_toFirestoreFields(project.toJson()));
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.createProject(project);
  }

  @override
  Future<ProjectItem> updateProject(ProjectItem project) async {
    try {
      final url = Uri.parse('$_endpoint/projects/${project.id}');
      final body = jsonEncode(_toFirestoreFields(project.toJson()));
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.updateProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final url = Uri.parse('$_endpoint/projects/$id');
      await http.delete(url).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    await _cache.deleteProject(id);
  }

  // --- Достижения ---
  @override
  Future<List<AchievementItem>> getAchievements() async {
    try {
      final url = Uri.parse('$_endpoint/achievements');
      final res = await http.get(url).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List docs = data['documents'] ?? [];
        return docs.map((d) => AchievementItem.fromJson(_fromFirestoreDocument(d))).toList();
      }
    } catch (_) {}
    return await _cache.getAchievements();
  }

  @override
  Future<AchievementItem> createAchievement(AchievementItem item) async {
    try {
      final docId = item.id.isNotEmpty ? item.id : DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse('$_endpoint/achievements?documentId=$docId');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_toFirestoreFields(item.toJson())),
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.createAchievement(item);
  }

  @override
  Future<AchievementItem> updateAchievement(AchievementItem item) async {
    try {
      final url = Uri.parse('$_endpoint/achievements/${item.id}');
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_toFirestoreFields(item.toJson())),
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.updateAchievement(item);
  }

  @override
  Future<void> deleteAchievement(String id) async {
    try {
      final url = Uri.parse('$_endpoint/achievements/$id');
      await http.delete(url).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    await _cache.deleteAchievement(id);
  }

  // --- Навыки ---
  @override
  Future<List<SkillItem>> getSkills() async {
    try {
      final url = Uri.parse('$_endpoint/skills');
      final res = await http.get(url).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List docs = data['documents'] ?? [];
        return docs.map((d) => SkillItem.fromJson(_fromFirestoreDocument(d))).toList();
      }
    } catch (_) {}
    return await _cache.getSkills();
  }

  @override
  Future<SkillItem> createSkill(SkillItem item) async {
    try {
      final docId = item.id.isNotEmpty ? item.id : DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse('$_endpoint/skills?documentId=$docId');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_toFirestoreFields(item.toJson())),
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.createSkill(item);
  }

  @override
  Future<SkillItem> updateSkill(SkillItem item) async {
    try {
      final url = Uri.parse('$_endpoint/skills/${item.id}');
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_toFirestoreFields(item.toJson())),
      ).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    return await _cache.updateSkill(item);
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      final url = Uri.parse('$_endpoint/skills/$id');
      await http.delete(url).timeout(ApiConfig.requestTimeout);
    } catch (_) {}
    await _cache.deleteSkill(id);
  }
}
