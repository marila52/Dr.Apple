import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/kcal_calculator.dart';
import '../onboarding/welcome_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/favorites_screen.dart';
import '../profile/settings_screen.dart';
import 'diary_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _genderLabel(Gender? gender) {
    switch (gender) {
      case Gender.female:
        return 'жен';
      case Gender.male:
        return 'муж';
      default:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDataProvider>().currentUser;
    final email = user?.email ?? context.read<CustomAuthProvider>().user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildProfileHeader(context, user?.name ?? 'Имя пользователя', email),
                    const SizedBox(height: 24),
                    _buildStatsGrid(user),
                    const SizedBox(height: 28),
                    _menuTile(
                      context,
                      title: 'Дневник питания',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiaryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuTile(
                      context,
                      title: 'Статистика',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuTile(
                      context,
                      title: 'Избранное',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuTile(
                      context,
                      title: 'Настройки',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.read<CustomAuthProvider>().signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => WelcomeScreen()),
                            (_) => false,
                          );
                        },
                        child: Text(
                          'Выйти из аккаунта',
                          style: AppFonts.roboto(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: AppColors.primaryDark),
            label: Text(
              'Назад',
              style: AppFonts.roboto(
                fontSize: 16,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Профиль',
            style: AppFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFC4C4C4),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.person, size: 40, color: AppColors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppFonts.roboto(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: Text(
                  'Редактировать',
                  style: AppFonts.roboto(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AppUser? user) {
    final chips = <String>[
      if (user?.weight != null) '${user!.weight!.toStringAsFixed(0)} кг',
      if (user?.height != null) '${user!.height!.toStringAsFixed(0)} см',
      if (user?.age != null) '${user!.age} лет',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < chips.length && i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _statChip(chips[i])),
            ],
          ],
        ),
        if (user != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _statChip(
                  '${user.dailyCalories?.round() ?? 0} ккал/день',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _statChip(_genderLabel(user.gender))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.roboto(
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}