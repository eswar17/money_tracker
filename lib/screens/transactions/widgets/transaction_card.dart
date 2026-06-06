import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../helpers/app_emoji_helper.dart';
import '../../../models/transaction_model.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  final VoidCallback onEdit;

  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == AppStrings.expense;

    final bool isIncome = transaction.type == AppStrings.income;

    final String amountPrefix = isExpense
        ? '-'
        : isIncome
        ? '+'
        : '';

    final Color amountColor = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.transfer;

    final subtitleItems = [
      transaction.category,
      transaction.paymentMethod,
      transaction.person,
      if (transaction.tag.isNotEmpty) transaction.tag,
      if (transaction.notes.isNotEmpty) transaction.notes,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      padding: const EdgeInsets.all(AppSpacing.sm),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: AppColors.divider.withValues(alpha: 0.30)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 8,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 48,

            width: 48,

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Center(
              child: Text(
                AppEmojiHelper.getEmoji(transaction.detail),

                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.detail,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      '$amountPrefix₹${transaction.amount.toStringAsFixed(0)}',

                      style: AppTextStyles.bodyMedium.copyWith(
                        color: amountColor,

                        fontSize: 16,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // PopupMenuButton<String>(
                    //   tooltip: '',

                    //   padding: EdgeInsets.zero,

                    //   color: Colors.white,

                    //   elevation: 8,

                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),

                    //   icon: Container(
                    //     padding: const EdgeInsets.all(6),

                    //     decoration: BoxDecoration(
                    //       color: Colors.grey.shade100,

                    //       borderRadius: BorderRadius.circular(10),
                    //     ),

                    //     child: Icon(
                    //       Icons.more_horiz_rounded,

                    //       size: 18,

                    //       color: Colors.grey.shade700,
                    //     ),
                    //   ),

                    //   onSelected: (value) {
                    //     if (value == AppStrings.edit) {
                    //       onEdit();
                    //     }

                    //     if (value == AppStrings.delete) {
                    //       onDelete();
                    //     }
                    //   },

                    //   itemBuilder: (context) {
                    //     return [
                    //       const PopupMenuItem(
                    //         value: AppStrings.edit,

                    //         child: Row(
                    //           children: [
                    //             Icon(Icons.edit_outlined, size: 18),

                    //             SizedBox(width: 10),

                    //             Text(AppStrings.edit),
                    //           ],
                    //         ),
                    //       ),

                    //       const PopupMenuItem(
                    //         value: AppStrings.delete,

                    //         child: Row(
                    //           children: [
                    //             Icon(Icons.delete_outline, size: 18),

                    //             SizedBox(width: 10),

                    //             Text(AppStrings.delete),
                    //           ],
                    //         ),
                    //       ),
                    //     ];
                    //   },
                    // ),
                  
                  ],
                ),

                Text(
                  subtitleItems.join(' • '),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
