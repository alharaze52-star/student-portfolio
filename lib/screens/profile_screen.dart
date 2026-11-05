import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/portfolio_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showApiSettingsDialog(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final urlController = TextEditingController(text: ApiConfig.customBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.cloud_sync_outlined, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text('Настройки API и БД', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Выберите источник данных:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    RadioListTile<ApiMode>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Node.js / Express REST API'),
                      subtitle: const Text('Локальный или серверный API'),
                      value: ApiMode.backendRest,
                      groupValue: provider.mode,
                      onChanged: (val) {
                        if (val != null) {
                          provider.setApiMode(val);
                          setDialogState(() {});
                        }
                      },
                    ),

                    RadioListTile<ApiMode>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Google Firebase Firestore API'),
                      subtitle: const Text('Прямой доступ к облачной БД через REST API'),
                      value: ApiMode.firebaseDirect,
                      groupValue: provider.mode,
                      onChanged: (val) {
                        if (val != null) {
                          provider.setApiMode(val);
                          setDialogState(() {});
                        }
                      },
                    ),

                    RadioListTile<ApiMode>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Автономный / Локальный кэш'),
                      subtitle: const Text('Работает 100% оффлайн без внешнего сервера'),
                      value: ApiMode.offlineMock,
                      groupValue: provider.mode,
                      onChanged: (val) {
                        if (val != null) {
                          provider.setApiMode(val);
                          setDialogState(() {});
                        }
                      },
                    ),

                    const Divider(height: 24),
                    const Text(
                      'URL адрес бэкенда:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        hintText: 'http://10.0.2.2:3000/api',
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Закрыть'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.setCustomBaseUrl(urlController.text.trim());
                    provider.loadAllData();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Применить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportPortfolioDialog(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final p = provider.profile;

    final summary = StringBuffer();
    summary.writeln('=== ЦИФРОВОЕ ПОРТФОЛИО СТУДЕНТА ===');
    summary.writeln('ФИО: ${p.fullName}');
    summary.writeln('Учебное заведение: ${p.university}');
    summary.writeln('Факультет/Группа: ${p.faculty}, гр. ${p.group}');
    summary.writeln('Средний балл (GPA): ${p.gpa}');
    summary.writeln('Email: ${p.email} | Тел: ${p.phone}');
    summary.writeln('\n--- ПРОЕКТЫ (${provider.projects.length}) ---');
    for (var proj in provider.projects) {
      summary.writeln('• ${proj.title} [${proj.status}] - ${proj.role}');
      summary.writeln('  Стек: ${proj.tags.join(", ")}');
      if (proj.githubUrl.isNotEmpty) summary.writeln('  GitHub: ${proj.githubUrl}');
    }
    summary.writeln('\n--- ДОСТИЖЕНИЯ (${provider.achievements.length}) ---');
    for (var a in provider.achievements) {
      summary.writeln('• ${a.title} (${a.place}) - ${a.issuer}, ${a.date}');
    }
    summary.writeln('\n--- НАВЫКИ (${provider.skills.length}) ---');
    for (var s in provider.skills) {
      summary.writeln('• ${s.name}: ${s.levelTitle} (${(s.level * 100).toInt()}%)');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сводка портфолио для резюме / защиты'),
        content: SingleChildScrollView(
          child: SelectableText(
            summary.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Портфолио скопировано в буфер обмена!')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Скопировать текст'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final profile = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String apiModeTitle;
    Color apiModeColor;
    switch (provider.mode) {
      case ApiMode.backendRest:
        apiModeTitle = 'Node.js Express API';
        apiModeColor = Colors.green;
        break;
      case ApiMode.firebaseDirect:
        apiModeTitle = 'Firebase Firestore API';
        apiModeColor = Colors.orange;
        break;
      case ApiMode.offlineMock:
        apiModeTitle = 'Автономный / Оффлайн кэш';
        apiModeColor = Colors.blue;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль студента'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать данные',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Profile Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(profile.avatarUrl),
                    onBackgroundImageError: (_, __) {},
                    child: profile.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 48, color: Color(0xFF4F46E5))
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),

                // University details
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_outlined, size: 18, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profile.university,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, size: 18, color: Colors.teal),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${profile.faculty} • Группа ${profile.group}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                // Bio
                Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          // Contacts section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Контакты',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Colors.indigo),
                  title: const Text('Email'),
                  subtitle: Text(profile.email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Colors.teal),
                  title: const Text('Телефон'),
                  subtitle: Text(profile.phone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code, color: Colors.deepPurple),
                  title: const Text('GitHub'),
                  subtitle: Text(profile.githubUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.send_outlined, color: Colors.blue),
                  title: const Text('Telegram'),
                  subtitle: Text(profile.telegramUrl),
                ),
              ],
            ),
          ),

          // System Settings & API section
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Системные параметры и API',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.cloud_done_outlined, color: apiModeColor),
                  title: const Text('Источник данных API'),
                  subtitle: Text(apiModeTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showApiSettingsDialog(context),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.amber,
                  ),
                  title: const Text('Темная тема оформления'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Включена' : 'Выключена'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: Color(0xFF10B981)),
                  title: const Text('Экспорт сводки портфолио'),
                  subtitle: const Text('Сформировать текст для резюме / защиты проекта'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportPortfolioDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Редактировать профиль'),
            ),
          ),
        ],
      ),
    );
  }
}

