import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_item.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/skill_progress_bar.dart';
import '../widgets/empty_state_view.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({Key? key}) : super(key: key);

  void _showSkillDialog(BuildContext context, {SkillItem? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String category = existing?.category ?? 'Hard Skills';
    double level = existing?.level ?? 0.8;
    String levelTitle = existing?.levelTitle ?? 'Продвинутый';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            void updateLevelTitle(double val) {
              if (val < 0.35) {
                levelTitle = 'Базовый';
              } else if (val < 0.70) {
                levelTitle = 'Средний';
              } else if (val < 0.90) {
                levelTitle = 'Продвинутый';
              } else {
                levelTitle = 'Эксперт';
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing != null ? 'Редактировать навык' : 'Новый навык',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название навыка *',
                      hintText: 'Dart / Flutter / Git / Английский язык',
                      prefixIcon: Icon(Icons.psychology_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Категория'),
                    items: ['Hard Skills', 'Soft Skills', 'Инструменты', 'Языки'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList>,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Уровень владения:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$levelTitle (${(level * 100).toInt()}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          )),
                    ],
                  ),
                  Slider(
                    value: level,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    onChanged: (val) {
                      setDialogState(() {
                        level = val;
                        updateLevelTitle(val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        final provider = context.read<PortfolioProvider>();

                        final item = SkillItem(
                          id: existing?.id ?? '',
                          name: nameController.text.trim(),
                          category: category,
                          level: level,
                          levelTitle: levelTitle,
                        );

                        if (existing != null) {
                          await provider.updateSkill(item);
                        } else {
                          await provider.createSkill(item);
                        }
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      },
                      child: Text(existing != null ? 'Сохранить' : 'Добавить навык'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final skills = provider.skills;

    // Группировка по категориям
    final Map<String, List<SkillItem>> grouped = {};
    for (var s in skills) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Компетенции и навыки'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSkillDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить навык'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadAllData(),
        child: skills.isEmpty
            ? EmptyStateView(
                title: 'Навыки не указаны',
                description: 'Добавьте ваши технические и коммуникативные навыки с уровнем владения.',
                icon: Icons.psychology_outlined,
                buttonText: 'Добавить навык',
                onAction: () => _showSkillDialog(context),
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      ...entry.value.map((skill) {
                        return SkillProgressBar(
                          skill: skill,
                          onEdit: () => _showSkillDialog(context, existing: skill),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Удалить навык?'),
                                content: Text('Удалить "${skill.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.deleteSkill(skill.id);
                            }
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
