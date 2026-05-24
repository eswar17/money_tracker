import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppTextField
    extends StatelessWidget {

  final String hint;

  final IconData icon;

  final TextEditingController?
      controller;

  final int maxLines;

  final TextInputType?
      keyboardType;

  final Widget? suffixIcon;

  const AppTextField({

    super.key,

    required this.hint,

    required this.icon,

    this.controller,

    this.maxLines = 1,

    this.keyboardType,

    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radius,
        ),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: TextField(

        controller: controller,

        maxLines: maxLines,

        keyboardType: keyboardType,

        decoration: InputDecoration(

          border: InputBorder.none,

          icon: Icon(
            icon,
            color:
                AppColors.textSecondary,
          ),

          hintText: hint,

          hintStyle: const TextStyle(
            color:
                AppColors.textSecondary,
          ),

          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}