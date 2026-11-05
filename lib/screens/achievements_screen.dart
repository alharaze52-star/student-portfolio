import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/achievement_card.dart';
import '../widgets/empty_state_view.dart';
import 'achievement_edit_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final achievements = provider.achievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения и грамоты'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementEditScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить грамоту'),
      ),
      body: Column(
        children: [
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['Все', 'Хакатон', 'Олимпиада', 'Наука', 'Сертификат', 'Конференция'].map((cat) {
                final isSelected = provider.achievementCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => provider.setAchievementCategoryFilter(cat),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.18),
                  ),
                );
              }).toList(),
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadAllData(),
              child: achievements.isEmpty
                  ? EmptyStateView(
                      title: 'Грамоты не найдены',
                      description: 'В этой категории пока нет записей. Добавьте победу в олимпиаде или сертификат!',
                      icon: Icons.military_tech_outlined,
                      buttonText: 'Добавить достижение',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AchievementEditScreen()),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: achievements.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final item = achievements[index];
                        return AchievementCard(
                          achievement: item,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AchievementEditScreen(achievement: item),
                              ),
                            );
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Удалить достижение?'),
                                content: Text('Удалить "${item.title}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.deleteAchievement(item.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

