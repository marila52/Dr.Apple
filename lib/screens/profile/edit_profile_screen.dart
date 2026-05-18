import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/kcal_calculator.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  Gender? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserDataProvider>().currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _ageController.text = user?.age?.toString() ?? '';
    _weightController.text = user?.weight?.toStringAsFixed(1) ?? '';
    _gender = user?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<UserDataProvider>();
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));

    setState(() => _saving = true);

    final ok = await provider.updateProfile(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      age: age,
      weight: weight,
      gender: _gender,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Не удалось сохранить')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppBackHeader(title: 'Редактирование профиля'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFC4C4C4),
                      child: Icon(Icons.person, size: 48, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Изменить фото',
                      style: AppFonts.roboto(
                        fontSize: 13,
                        color: AppColors.spiralPink,
                      ),
                    ),
                    const Divider(height: 32, color: AppColors.border),
                    _pillField(_nameController, 'Имя :'),
                    const SizedBox(height: 12),
                    _pillField(_emailController, 'Почта :', readOnly: true),
                    const SizedBox(height: 12),
                    _genderField(),
                    const SizedBox(height: 12),
                    _pillField(_ageController, 'Возраст :', number: true),
                    const SizedBox(height: 12),
                    _pillField(_weightController, 'Вес :', number: true),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSage,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _saving
                      ? const SpiralLoader(size: 28)
                      : Text('ГОТОВО', style: AppFonts.roboto(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillField(TextEditingController c, String label, {bool number = false, bool readOnly = false}) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: AppFonts.roboto(color: AppColors.primaryDark)),
        ),
        Expanded(
          child: TextField(
            controller: c,
            readOnly: readOnly,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE9E0DD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderField() {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text('Пол :', style: AppFonts.roboto(color: AppColors.primaryDark)),
        ),
        Expanded(
          child: DropdownButtonFormField<Gender>(
            value: _gender,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE9E0DD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
            items: const [
              DropdownMenuItem(value: Gender.female, child: Text('Женский')),
              DropdownMenuItem(value: Gender.male, child: Text('Мужской')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
        ),
      ],
    );
  }
}
