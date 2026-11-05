import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement_item.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/custom_text_field.dart';

class AchievementEditScreen extends StatefulWidget {
  final AchievementItem? achievement;

  const AchievementEditScreen({Key? key, this.achievement}) : super(key: key);

  @override
  State<AchievementEditScreen> createState() => _AchievementEditScreenState();
}

class _AchievementEditScreenState extends State<AchievementEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _issuerController;
  late TextEditingController _dateController;
  late TextEditingController _placeController;
  late TextEditingController _descController;
  late String _category;

  @override
  void initState() {
    super.initState();
    final a = widget.achievement;
    _titleController = TextEditingController(text: a?.title ?? '');
    _issuerController = TextEditingController(text: a?.issuer ?? '');
    _dateController = TextEditingController(text: a?.date ?? '');
    _placeController = TextEditingController(text: a?.place ?? '1 место');
    _descController = TextEditingController(text: a?.description ?? '');
    _category = a?.category ?? 'Хакатон';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _placeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PortfolioProvider>();
    final isEditing = widget.achievement != null;

    final item = AchievementItem(
      id: widget.achievement?.id ?? '',
      title: _titleController.text.trim(),
      category: _category,
      issuer: _issuerController.text.trim(),
      date: _dateController.text.trim(),
      place: _placeController.text.trim(),
      description: _descController.text.trim(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateAchievement(item);
    } else {
      success = await provider.createAchievement(item);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Достижение обновлено' : 'Достижение добавлено'),
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
    final isEditing = widget.achievement != null;
    final isSaving = context.watch<PortfolioProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать достижение' : 'Новое достижение'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Название диплома / грамоты *',
              hint: 'Например, Победитель кейс-чемпионата',
              prefixIcon: Icons.emoji_events_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
            ),

            const Text(
              'Категория *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ['Хакатон', 'Олимпиада', 'Наука', 'Сертификат', 'Конференция', 'Спорт'].map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _placeController,
              label: 'Результат / Место',
              hint: '1 место, Финалист, Гран-при, Сертификат с отличием',
              prefixIcon: Icons.military_tech_outlined,
            ),
            CustomTextField(
              controller: _issuerController,
              label: 'Организатор / Кем выдано *',
              hint: 'Например, Правительство Москвы, ВШЭ, Яндекс',
              prefixIcon: Icons.account_balance_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Укажите организатора' : null,
            ),
            CustomTextField(
              controller: _dateController,
              label: 'Дата вручения',
              hint: 'Например, Октябрь 2024',
              prefixIcon: Icons.calendar_today_outlined,
            ),
            CustomTextField(
              controller: _descController,
              label: 'Краткое пояснение',
              hint: 'За что награда, тематика работы...',
              maxLines: 3,
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
                  : Text(isEditing ? 'Сохранить изменения' : 'Добавить в портфолио'),
            ),
          ],
        ),
      ),
    );
  }
}
