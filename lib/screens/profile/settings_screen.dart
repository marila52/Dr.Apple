import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/database/product_dao.dart';
import '../../services/database/settings_dao.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';
import 'developers_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsDao _settingsDao = SettingsDao();
  bool _reminders = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;
    final all = await _settingsDao.getAll(userId);
    if (mounted) {
      setState(() {
        _reminders = all['reminders'] != 'false';
        _loading = false;
      });
    }
  }

  Future<void> _set(String key, bool value) async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;
    await _settingsDao.set(userId, key, value.toString());
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить кэш?'),
        content: const Text('Будут удалены кэшированные продукты из локальной базы.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Очистить')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ProductDao().deleteAllProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Кэш продуктов очищен')),
      );
    }
  }

  void _openDevelopers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DevelopersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppBackHeader(title: 'Настройки'),
            if (_loading)
              const Expanded(child: Center(child: SpiralLoader(size: 56)))
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _switchTile(
                      'Напоминания о приёмах пищи',
                      _reminders,
                      (v) {
                        setState(() => _reminders = v);
                        _set('reminders', v);
                      },
                    ),
                    const SizedBox(height: 16),
                    _actionTile('Очистить кэш продуктов', _clearCache),
                    _actionTile('Разработчики', _openDevelopers),
                    _actionTile('Версия приложения', null, subtitle: '1.0.0'),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Image.asset(
                        'assets/images/settings.jpg',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 300,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue, width: 1.5),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppFonts.prata(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        activeColor: AppColors.white,
        activeTrackColor: AppColors.blue,
        inactiveThumbColor: AppColors.white,
        inactiveTrackColor: Colors.grey.shade300,
        onChanged: onChanged,
      ),
    );
  }

  Widget _actionTile(String title, VoidCallback? onTap, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue, width: 1.5),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppFonts.prata(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppFonts.prata(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}