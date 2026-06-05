import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
class AppButton
    extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppSpacing.radius,
            ),
          ),
        ),
        child: Text(
          title,
          style:
              AppTextStyles.button,
        ),
      ),
    );
  }
}