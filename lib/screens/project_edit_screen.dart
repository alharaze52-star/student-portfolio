import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_item.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/custom_text_field.dart';

class ProjectEditScreen extends StatefulWidget {
  final ProjectItem? project;

  const ProjectEditScreen({Key? key, this.project}) : super(key: key);

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _roleController;
  late TextEditingController _tagsController;
  late TextEditingController _githubUrlController;
  late TextEditingController _demoUrlController;
  late TextEditingController _periodController;

  late String _status;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _roleController = TextEditingController(text: p?.role ?? 'Разработчик');
    _tagsController = TextEditingController(text: p?.tags.join(', ') ?? '');
    _githubUrlController = TextEditingController(text: p?.githubUrl ?? '');
    _demoUrlController = TextEditingController(text: p?.demoUrl ?? '');
    _periodController = TextEditingController(text: p?.period ?? '');
    _status = p?.status ?? 'Завершен';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roleController.dispose();
    _tagsController.dispose();
    _githubUrlController.dispose();
    _demoUrlController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PortfolioProvider>();

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final isEditing = widget.project != null;

    final projectItem = ProjectItem(
      id: widget.project?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      role: _roleController.text.trim(),
      status: _status,
      tags: tags,
      githubUrl: _githubUrlController.text.trim(),
      demoUrl: _demoUrlController.text.trim(),
      period: _periodController.text.trim(),
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateProject(projectItem);
    } else {
      success = await provider.createProject(projectItem);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Проект успешно обновлен' : 'Проект успешно добавлен'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Ошибка сохранения'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    final isSaving = context.watch<PortfolioProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать проект' : 'Новый проект'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Название проекта *',
              hint: 'Например, Мобильное приложение для кампуса',
              prefixIcon: Icons.title,
              validator: (val) => val == null || val.trim().isEmpty ? 'Введите название проекта' : null,
            ),
            CustomTextField(
              controller: _roleController,
              label: 'Ваша роль *',
              hint: 'Например, Lead Flutter Developer, Архитектор',
              prefixIcon: Icons.badge_outlined,
              validator: (val) => val == null || val.trim().isEmpty ? 'Укажите вашу роль' : null,
            ),

            // Dropdown Status
            const Text(
              'Статус выполнения *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ['Завершен', 'В разработке', 'Планируется'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _periodController,
              label: 'Период разработки',
              hint: 'Например, Сентябрь 2024 - Ноябрь 2024',
              prefixIcon: Icons.calendar_today_outlined,
            ),
            CustomTextField(
              controller: _tagsController,
              label: 'Стек технологий (через запятую)',
              hint: 'Flutter, Dart, Firebase, REST API, Git',
              prefixIcon: Icons.tag,
            ),
            CustomTextField(
              controller: _descriptionController,
              label: 'Подробное описание *',
              hint: 'Опишите назначение проекта, решенные задачи, функционал и результаты...',
              maxLines: 4,
              validator: (val) => val == null || val.trim().isEmpty ? 'Добавьте описание' : null,
            ),
            CustomTextField(
              controller: _githubUrlController,
              label: 'Ссылка на репозиторий GitHub',
              hint: 'https://github.com/username/project',
              prefixIcon: Icons.code,
              keyboardType: TextInputType.url,
            ),
            CustomTextField(
              controller: _demoUrlController,
              label: 'Ссылка на демо / релиз',
              hint: 'https://demo-app.com',
              prefixIcon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEditing ? 'Сохранить изменения' : 'Добавить проект в портфолио'),
            ),
          ],
        ),
      ),
    );
  }
}
