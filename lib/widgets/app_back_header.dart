import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../theme/app_colors.dart';

class AppBackHeader extends StatelessWidget {
  const AppBackHeader({
    super.key,
    this.title,
    this.trailing,
    this.onBack,
  });

  final String? title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          // Розовая стрелка
          IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFFFA2C3),
              size: 24,
            ),
          ),
          
          // Картинка up.png
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/images/up.png',
              width: 200,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          
          // Заголовок с Expanded, чтобы не было переполнения
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppFonts.prata(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          
          // Иконка справа (если передана)
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}