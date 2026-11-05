import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/empty_state_view.dart';
import 'project_detail_screen.dart';
import 'project_edit_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final projects = provider.projects;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Проекты'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectEditScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить проект'),
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => provider.setProjectSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Поиск по названию, описанию или тегу...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.projectSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.setProjectSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['Все', 'Завершен', 'В разработке'].map((status) {
                final isSelected = provider.projectStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => provider.setProjectStatusFilter(status),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.18),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Projects List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadAllData(),
              child: projects.isEmpty
                  ? EmptyStateView(
                      title: 'Проекты не найдены',
                      description: 'Попробуйте изменить параметры поиска или добавьте новый проект.',
                      icon: Icons.code_off,
                      buttonText: 'Создать проект',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProjectEditScreen()),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: projects.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final project = projects[index];
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
                                content: Text('Вы действительно хотите удалить "${project.title}"?'),
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
                              provider.deleteProject(project.id);
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
