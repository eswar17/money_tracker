import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../helpers/app_emoji_helper.dart';
import '../../../models/transaction_model.dart';
import '../../../constants/app_strings.dart';
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

    final Color amountColor = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                      '${isExpense ? '-' : '+'}₹${transaction.amount.toStringAsFixed(0)}',

                      style: AppTextStyles.bodyMedium.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),

                      icon: Icon(
                        Icons.more_vert,

                        size: 14,

                        color: Colors.grey.shade500,
                      ),

                      onSelected: (value) {
                        if (value == AppStrings.edit) {
                          onEdit();
                        }

                        if (value == AppStrings.delete) {
                          onDelete();
                        }
                      },

                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: AppStrings.edit,

                            child: Text(AppStrings.edit),
                          ),

                          const PopupMenuItem(
                            value: AppStrings.delete,

                            child: Text(AppStrings.delete),
                          ),
                        ];
                      },
                    ),
                  ],
                ),

                Text(
                  '${transaction.category} • ${transaction.paymentMethod} • ${transaction.person} • ${transaction.tag}${transaction.notes.isNotEmpty ? ' • ${transaction.notes}' : ''}',

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
