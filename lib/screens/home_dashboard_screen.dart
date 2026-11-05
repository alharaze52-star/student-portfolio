import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/project_card.dart';
import '../widgets/achievement_card.dart';
import 'project_detail_screen.dart';
import 'project_edit_screen.dart';
import 'achievement_edit_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({Key? key, required this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final profile = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Цифровое портфолио'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить данные из API',
            onPressed: () => provider.loadAllData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Student Header Banner ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundImage: NetworkImage(profile.avatarUrl),
                            onBackgroundImageError: (_, __) {},
                            child: profile.avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 36, color: Color(0xFF4F46E5))
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.title,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${profile.group} • Средний балл: ${profile.gpa}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Quick Stats Grid ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Проекты',
                        value: provider.totalProjectsCount.toString(),
                        icon: Icons.code,
                        color: const Color(0xFF4F46E5),
                        onTap: () => onNavigateTab(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Достижения',
                        value: provider.totalAchievementsCount.toString(),
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFEC4899),
                        onTap: () => onNavigateTab(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Навыки',
                        value: provider.totalSkillsCount.toString(),
                        icon: Icons.psychology_outlined,
                        color: const Color(0xFF10B981),
                        onTap: () => onNavigateTab(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Завершено',
                        value: provider.completedProjectsCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF06B6D4),
                        onTap: () => onNavigateTab(1),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Quick Actions ---
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProjectEditScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Новый проект'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AchievementEditScreen()),
                          );
                        },
                        icon: const Icon(Icons.military_tech_outlined, size: 18),
                        label: const Text('Новая грамота'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Featured Projects Section ---
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ключевые проекты',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Text('Все проекты →'),
                    ),
                  ],
                ),
              ),
              if (provider.allProjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет добавленных проектов'),
                )
              else
                ...provider.allProjects.take(2).map((project) {
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectEditScreen(project: project),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Удалить проект?'),
                          content: Text('Вы уверены, что хотите удалить "${project.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.deleteProject(project.id);
                      }
                    },
                  );
                }),

              // --- Recent Achievements Section ---
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Недавние достижения',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(2),
                      child: const Text('Все достижения →'),
                    ),
                  ],
                ),
              ),
              if (provider.allAchievements.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет добавленных достижений'),
                )
              else
                ...provider.allAchievements.take(2).map((achievement) {
                  return AchievementCard(
                    achievement: achievement,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AchievementEditScreen(achievement: achievement),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Удалить достижение?'),
                          content: Text('Удалить "${achievement.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.deleteAchievement(achievement.id);
                      }
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

