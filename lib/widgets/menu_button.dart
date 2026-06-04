import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const MenuButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),

        decoration: BoxDecoration(
          color: AppColors.card,

          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),

        child: const Icon(Icons.menu_rounded),
      ),
    );
  }
}
