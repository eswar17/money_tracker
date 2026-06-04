import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class PersonBattleCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PersonBattleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> personSpent = Map<String, double>.from(
      data['personSpent'] ?? {},
    );

    if (personSpent.isEmpty) {
      return const SizedBox.shrink();
    }

    final ranking = personSpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = ranking.fold<double>(0, (sum, e) => sum + e.value);

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
                child: const Text('🏆', style: TextStyle(fontSize: 17)),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spending Ranking', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${ranking.first.key} spent the most this month',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...ranking.asMap().entries.map((entry) {
            final index = entry.key;

            final person = entry.value.key;

            final amount = entry.value.value;

            final double percent = total == 0 ? 0.0 : amount / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: personTile(
                rank: index + 1,
                name: person,
                amount: amount,
                percent: percent,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget personTile({
    required int rank,
    required String name,
    required double amount,
    required double percent,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Text('#$rank', style: AppTextStyles.heading3),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyLarge),

                const SizedBox(height: 4),

                LinearProgressIndicator(value: percent),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text('₹${amount.toStringAsFixed(0)}', style: AppTextStyles.heading3),
        ],
      ),
    );
  }
}
