import 'package:flutter/material.dart';
import '../../../theme/app_text_styles.dart';

class SummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const SummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double income = (data['income'] ?? 0).toDouble();

    final double expense = (data['expense'] ?? 0).toDouble();

    final double savings = (data['savings'] ?? 0).toDouble();

    final double savingsRate = income == 0 ? 0 : (savings / income) * 100;

    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.25),

            blurRadius: 25,

            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Text('📊', style: TextStyle(fontSize: 17)),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Monthly Summary',

                    style: AppTextStyles.heading3.copyWith(color: Colors.white, fontSize:15),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    'Your financial overview',

                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 3),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              summaryItem(emoji: '💰', title: 'Income', amount: income),

              summaryItem(emoji: '💸', title: 'Expense', amount: expense),

              summaryItem(emoji: '📈', title: 'Savings', amount: savings),
            ],
          ),

          const SizedBox(height: 3),

          Container(
            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Savings Rate',

                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${savingsRate.toStringAsFixed(1)}%',

                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Stack(
                  alignment: Alignment.center,

                  children: [
                    SizedBox(
                      height: 50,

                      width: 50,

                      child: CircularProgressIndicator(
                        value: (savingsRate / 100).clamp(0, 1),

                        strokeWidth: 8,

                        backgroundColor: Colors.white24,

                        valueColor: AlwaysStoppedAnimation(
                          savings >= 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ),

                    Text(
                      savings >= 0 ? '😎' : '😭',

                      style: const TextStyle(fontSize: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryItem({
    required String emoji,

    required String title,

    required double amount,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 17)),

          const SizedBox(height: 4),

          Text(
            title,

            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 3),

          Text(
            '₹${amount.toStringAsFixed(0)}',

            textAlign: TextAlign.center,

            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,

              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}
