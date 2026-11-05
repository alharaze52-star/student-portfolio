import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_profile.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/custom_text_field.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _universityController;
  late TextEditingController _facultyController;
  late TextEditingController _groupController;
  late TextEditingController _gpaController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _githubController;
  late TextEditingController _telegramController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    final p = context.read<PortfolioProvider>().profile;
    _nameController = TextEditingController(text: p.fullName);
    _titleController = TextEditingController(text: p.title);
    _universityController = TextEditingController(text: p.university);
    _facultyController = TextEditingController(text: p.faculty);
    _groupController = TextEditingController(text: p.group);
    _gpaController = TextEditingController(text: p.gpa.toString());
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _githubController = TextEditingController(text: p.githubUrl);
    _telegramController = TextEditingController(text: p.telegramUrl);
    _bioController = TextEditingController(text: p.bio);
    _avatarUrlController = TextEditingController(text: p.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _groupController.dispose();
    _gpaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    _telegramController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PortfolioProvider>();
    final current = provider.profile;

    final updated = current.copyWith(
      fullName: _nameController.text.trim(),
      title: _titleController.text.trim(),
      university: _universityController.text.trim(),
      faculty: _facultyController.text.trim(),
      group: _groupController.text.trim(),
      gpa: double.tryParse(_gpaController.text.trim()) ?? current.gpa,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      githubUrl: _githubController.text.trim(),
      telegramUrl: _telegramController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );

    final success = await provider.updateProfile(updated);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные профиля успешно сохранены в API'),
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
    final isSaving = context.watch<PortfolioProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'ФИО Студента *',
              hint: 'Иванов Иван Иванович',
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Введите ФИО' : null,
            ),
            CustomTextField(
              controller: _titleController,
              label: 'Специальность / Статус *',
              hint: 'Студент 3 курса, Flutter-разработчик',
              prefixIcon: Icons.badge_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Укажите специальность' : null,
            ),
            CustomTextField(
              controller: _universityController,
              label: 'Вуз / Колледж *',
              hint: 'Московский Политехнический Университет',
              prefixIcon: Icons.account_balance_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Укажите учебное заведение' : null,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _facultyController,
                    label: 'Факультет / Кафедра',
                    hint: 'Информационные технологии',
                    prefixIcon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    controller: _groupController,
                    label: 'Группа',
                    hint: 'ПИ-301',
                    prefixIcon: Icons.group_outlined,
                  ),
                ),
              ],
            ),
            CustomTextField(
              controller: _gpaController,
              label: 'Средний балл успеваемости (GPA)',
              hint: '4.85',
              prefixIcon: Icons.grade_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            CustomTextField(
              controller: _emailController,
              label: 'Контактный Email',
              hint: 'student@edu.ru',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: _phoneController,
              label: 'Телефон',
              hint: '+7 (999) 000-00-00',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              controller: _githubController,
              label: 'Профиль GitHub',
              hint: 'https://github.com/student',
              prefixIcon: Icons.code,
              keyboardType: TextInputType.url,
            ),
            CustomTextField(
              controller: _telegramController,
              label: 'Telegram',
              hint: '@username',
              prefixIcon: Icons.send_outlined,
            ),
            CustomTextField(
              controller: _avatarUrlController,
              label: 'URL Фотографии / Аватара',
              hint: 'https://images.unsplash.com/...',
              prefixIcon: Icons.image_outlined,
              keyboardType: TextInputType.url,
            ),
            CustomTextField(
              controller: _bioController,
              label: 'О себе / Краткая характеристика',
              hint: 'Расскажите о своих научных интересах, достижениях и карьерных целях...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Сохранить изменения в API'),
            ),
          ],
        ),
      ),
    );
  }
}
