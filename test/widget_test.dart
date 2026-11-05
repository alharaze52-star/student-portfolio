import 'package:flutter_test/flutter_test.dart';
import 'package:student_portfolio/models/student_profile.dart';
import 'package:student_portfolio/models/project_item.dart';
import 'package:student_portfolio/models/achievement_item.dart';
import 'package:student_portfolio/models/skill_item.dart';

void main() {
  group('Student Portfolio Models Test', () {
    test('StudentProfile model JSON serialization and deserialization', () {
      final profile = StudentProfile.empty();
      final json = profile.toJson();
      final fromJson = StudentProfile.fromJson(json);

      expect(fromJson.fullName, profile.fullName);
      expect(fromJson.university, profile.university);
      expect(fromJson.gpa, profile.gpa);
    });

    test('ProjectItem model JSON serialization', () {
      final project = ProjectItem(
        id: 'p1',
        title: 'Тестовый проект',
        description: 'Описание проекта',
        role: 'Разработчик',
        status: 'Завершен',
        tags: ['Flutter', 'Firebase'],
        period: '2024',
        createdAt: DateTime.now(),
      );

      final json = project.toJson();
      final fromJson = ProjectItem.fromJson(json);

      expect(fromJson.id, 'p1');
      expect(fromJson.title, 'Тестовый проект');
      expect(fromJson.tags.length, 2);
      expect(fromJson.status, 'Завершен');
    });

    test('AchievementItem model JSON serialization', () {
      final achievement = AchievementItem(
        id: 'a1',
        title: 'Хакатон ВШЭ',
        category: 'Хакатон',
        issuer: 'НИУ ВШЭ',
        date: '2024',
        place: '1 место',
      );

      final json = achievement.toJson();
      final fromJson = AchievementItem.fromJson(json);

      expect(fromJson.id, 'a1');
      expect(fromJson.place, '1 место');
      expect(fromJson.category, 'Хакатон');
    });

    test('SkillItem model JSON serialization', () {
      final skill = SkillItem(
        id: 's1',
        name: 'Flutter & Dart',
        category: 'Hard Skills',
        level: 0.9,
        levelTitle: 'Продвинутый',
      );

      final json = skill.toJson();
      final fromJson = SkillItem.fromJson(json);

      expect(fromJson.name, 'Flutter & Dart');
      expect(fromJson.level, 0.9);
      expect(fromJson.levelTitle, 'Продвинутый');
    });
  });
}
