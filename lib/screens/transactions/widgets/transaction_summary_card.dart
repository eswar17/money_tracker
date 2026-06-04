import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class TransactionSummaryCard extends StatelessWidget {
  final String title;

  final double amount;

  final Color color;

  const TransactionSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(
            title,

            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '₹${amount.toStringAsFixed(0)}',

            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
