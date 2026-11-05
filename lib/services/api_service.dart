import '../models/student_profile.dart';
import '../models/project_item.dart';
import '../models/achievement_item.dart';
import '../models/skill_item.dart';

abstract class ApiService {
  // Профиль
  Future<StudentProfile> getProfile();
  Future<StudentProfile> updateProfile(StudentProfile profile);

  // Проекты
  Future<List<ProjectItem>> getProjects();
  Future<ProjectItem> createProject(ProjectItem project);
  Future<ProjectItem> updateProject(ProjectItem project);
  Future<void> deleteProject(String id);

  // Достижения
  Future<List<AchievementItem>> getAchievements();
  Future<AchievementItem> createAchievement(AchievementItem item);
  Future<AchievementItem> updateAchievement(AchievementItem item);
  Future<void> deleteAchievement(String id);

  // Навыки
  Future<List<SkillItem>> getSkills();
  Future<SkillItem> createSkill(SkillItem item);
  Future<SkillItem> updateSkill(SkillItem item);
  Future<void> deleteSkill(String id);
}

