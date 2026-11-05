import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_item.dart';
import '../providers/portfolio_provider.dart';
import 'project_edit_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectItem project;

  const ProjectDetailScreen({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    // Находим актуальную версию проекта из провайдера, если он был обновлен
    final currentProject = provider.allProjects.firstWhere(
      (p) => p.id == project.id,
      orElse: () => project,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectEditScreen(project: currentProject),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить проект?'),
                  content: Text('Удалить "${currentProject.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.deleteProject(currentProject.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and period bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentProject.status,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (currentProject.period.isNotEmpty)
                  Text(
                    currentProject.period,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              currentProject.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Role
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 18, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Роль в команде: ${currentProject.role}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tags
            if (currentProject.tags.isNotEmpty) ...[
              const Text(
                'Стек технологий',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentProject.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Description
            const Text(
              'Описание проекта',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                currentProject.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Links section (GitHub / Demo)
            if (currentProject.githubUrl.isNotEmpty || currentProject.demoUrl.isNotEmpty) ...[
              const Text(
                'Ссылки и репозиторий',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (currentProject.githubUrl.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.code, color: Colors.white, size: 20),
                  ),
                  title: const Text('Исходный код на GitHub'),
                  subtitle: Text(
                    currentProject.githubUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ссылка: ${currentProject.githubUrl}')),
                    );
                  },
                ),
              if (currentProject.demoUrl.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF06B6D4),
                    child: Icon(Icons.link, color: Colors.white, size: 20),
                  ),
                  title: const Text('Демонстрация / Релиз'),
                  subtitle: Text(
                    currentProject.demoUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ссылка: ${currentProject.demoUrl}')),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

