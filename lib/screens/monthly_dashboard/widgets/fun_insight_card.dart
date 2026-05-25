import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class FunInsightCard extends StatelessWidget {
  final String insight;

  const FunInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final bool danger = insight.contains('💀') || insight.contains('😭');

    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: danger
              ? [const Color(0xFFFFE0E0), const Color(0xFFFFF3E0)]
              : [const Color(0xFFE3F2FD), const Color(0xFFE8F5E9)],
        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 60,

            width: 60,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                danger ? '😭' : '😎',

                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text('Fun Insight', style: AppTextStyles.heading3),

                const SizedBox(height: 8),

                Text(
                  insight,

                  style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,

                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Text(
                    danger
                        ? '⚠️ Spending needs attention'
                        : '📈 Financial vibe looks healthy',

                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
