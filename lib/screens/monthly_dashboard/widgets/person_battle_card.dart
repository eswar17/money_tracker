import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class PersonBattleCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PersonBattleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double eswarSpent = (data['eswarSpent'] ?? 0).toDouble();

    final double lathaSpent = (data['lathaSpent'] ?? 0).toDouble();

    final bool eswarWon = eswarSpent > lathaSpent;

    final bool equal = eswarSpent == lathaSpent;

    String winnerText = '🤝 Equal Spending';

    String reasonText = 'Perfect balance this month';

    String winnerEmoji = '🤝';

    if (!equal) {
      winnerText = eswarWon ? '👨 Eswar Spent More' : '👩 Latha Spent More';

      winnerEmoji = eswarWon ? '💸' : '🛍️';

      reasonText = eswarWon
          ? 'Eswar dominated the expenses this month 😭'
          : 'Latha carried the spending crown this month 😎';
    }

    final double total = eswarSpent + lathaSpent;

    final double eswarPercent = total == 0 ? 0 : eswarSpent / total;

    final double lathaPercent = total == 0 ? 0 : lathaSpent / total;

    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),

                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Text('⚔️', style: TextStyle(fontSize: 17)),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Spending Battle', style: AppTextStyles.bodyLarge),

                  const SizedBox(height: 2),

                  Text(winnerText, style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          Row(
            children: [
              Expanded(
                child: personTile(
                  emoji: '👨',

                  name: 'Eswar',

                  amount: eswarSpent,

                  percent: eswarPercent,
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: personTile(
                  emoji: '👩',

                  name: 'Latha',

                  amount: lathaSpent,

                  percent: lathaPercent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Container(
            padding: const EdgeInsets.all(5),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.15),

                  Colors.pink.withOpacity(0.10),
                ],
              ),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              children: [
                Text(winnerEmoji, style: const TextStyle(fontSize: 28)),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(reasonText, style: AppTextStyles.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget personTile({
    required String emoji,

    required String name,

    required double amount,

    required double percent,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),

          const SizedBox(height: 1),

          Text(
            name,

            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 1),

          Text('₹${amount.toStringAsFixed(0)}', style: AppTextStyles.heading3),

          const SizedBox(height: 4),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: percent,

              minHeight: 10,

              backgroundColor: Colors.grey.shade300,

              valueColor: AlwaysStoppedAnimation(
                percent > 0.5 ? Colors.red : Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${(percent * 100).toStringAsFixed(1)}%',

            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
