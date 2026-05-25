import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class MonthlyInsightsSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const MonthlyInsightsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List achievements = data['achievements'] ?? [];

    final List warnings = data['warnings'] ?? [];

    return Column(
      children: [
        // =====================
        // QUICK INSIGHTS
        // =====================
        GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 3,

          crossAxisSpacing: 15,

          childAspectRatio: 2.5,

          children: [
            compactInsightTile(
              emoji: '🧘',

              title: 'No Spend Days',

              value: '${data['noSpendDays']}',
            ),

            compactInsightTile(
              emoji: '🔥',

              title: 'Spending Streak',

              value: '${data['spendingStreak']} Days',
            ),
          ],
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 3,

          crossAxisSpacing: 15,

          childAspectRatio: 2,

          children: [

            compactInsightTile(
              emoji: '💸',

              title: 'Most Expensive Day',

              value:
                  '₹${(data['mostExpensiveDay']['amount'] as double).toStringAsFixed(0)} on ${data['mostExpensiveDay']['day']}',
            ),

            compactInsightTile(
              emoji: '📊',

              title: 'Month Comparison',

              value: data['monthComparison'],
            ),
          ],
        ),
        
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 1,

          crossAxisSpacing: 1,

          childAspectRatio: 2.2,

          children: [
            compactInsightTile(
              emoji: '😎',

              title: 'Financial Mood',

              value: data['financialMood'],
            ),

            compactInsightTile(
              emoji: '💳',

              title: 'Credit Pressure',

              value: data['creditCardPressure'],
            ),
          ],
        ),
        
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 1,

          crossAxisSpacing: 1,

          childAspectRatio: 2.2,

          children: [
            compactInsightTile(
              emoji: '🏆',

              title: 'Savings Title',

              value: data['savingsTitle'],
            ),
            compactInsightTile(
              emoji: '🍔',

              title: 'Category Domination',

              value: data['categoryDomination'],
            ),
          ],
        ),

        // const SizedBox(height: 5),

        // // =====================
        // // CATEGORY DOMINATION
        // // =====================
        // fullWidthCard(
        //   emoji: '🍔',

        //   title: 'Category Domination',

        //   value: data['categoryDomination'],
        // ),

        const SizedBox(height: 10),
        // =====================
        // ACHIEVEMENTS
        // =====================
        if (achievements.isNotEmpty) ...[
          const SizedBox(height: 5),

          sectionCard(
            emoji: '🏅',

            title: 'Achievements',

            children: achievements.map<Widget>((achievement) {
              return listTile(achievement);
            }).toList(),
          ),
        ],

        // =====================
        // WARNINGS
        // =====================
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 5),

          sectionCard(
            emoji: '⚠️',

            title: 'Smart Warnings',

            children: warnings.map<Widget>((warning) {
              return listTile(warning);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget insightTile({
    required String emoji,

    required String title,

    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),

          const SizedBox(height: 5),

          Text(value, style: AppTextStyles.heading3),

          const SizedBox(height: 5),

          Text(
            title,

            textAlign: TextAlign.center,

            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget fullWidthCard({
    required String emoji,

    required String title,

    required String value,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: AppTextStyles.bodySmall),

                const SizedBox(height: 1),

                Text(
                  value,

                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({
    required String emoji,

    required String title,

    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),

              const SizedBox(width: 1),

              Text(title, style: AppTextStyles.heading3),
            ],
          ),

          const SizedBox(height: 5),

          ...children,
        ],
      ),
    );
  }

  Widget listTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text('• '),

          Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }

  Widget compactInsightTile({
    required String emoji,

    required String title,

    required String value,

    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: color ?? Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 14,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            emoji + " " + title,
            style: AppTextStyles.heading3.copyWith(fontSize: 12),
          ),

          const SizedBox(height: 8),

          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),

          //const SizedBox(height: 1),

          //Text(title, style: AppTextStyles.bodyLarge.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
