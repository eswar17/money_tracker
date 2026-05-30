class CategoryInsightsGenerator {
  static List<Map<String, dynamic>> generateInsights({
    required List<Map<String, dynamic>> analytics,
    required double totalExpense,
    required String? topCategory,
    required double topCategoryAmount,
    required double topCategoryPercentage,
    required double spendingFocus,
    required double needsPercentage,
    required double wantsPercentage,
    required double futurePercentage,
  }) {
    final insights = <Map<String, dynamic>>[];

    void addInsight({
      required String emoji,
      required int color,
      required String text,
    }) {
      insights.add({'emoji': emoji, 'color': color, 'text': text});
    }

    // --------------------
    // GLOBAL INSIGHTS
    // --------------------

    if (topCategoryPercentage >= 40) {
      addInsight(
        emoji: '👑',
        color: 0xFFC86BFF,
        text:
            '$topCategory dominates spending at ${topCategoryPercentage.toStringAsFixed(0)}%.',
      );
    }

    if (spendingFocus >= 75) {
      addInsight(
        emoji: '⚠️',
        color: 0xFFFF5C5C,
        text:
            'Top categories consume ${spendingFocus.toStringAsFixed(0)}% of spending.',
      );
    }

    if (futurePercentage >= 15) {
      addInsight(
        emoji: '🏦',
        color: 0xFF00E5B0,
        text:
            'Future-focused spending reached ${futurePercentage.toStringAsFixed(0)}%.',
      );
    }

    if (wantsPercentage >= 35) {
      addInsight(
        emoji: '🛍️',
        color: 0xFFFFA500,
        text:
            'Wants account for ${wantsPercentage.toStringAsFixed(0)}% of spending.',
      );
    }

    if (needsPercentage >= 70) {
      addInsight(
        emoji: '📌',
        color: 0xFF4DA3FF,
        text:
            'Most spending is going towards essentials (${needsPercentage.toStringAsFixed(0)}%).',
      );
    }

    // --------------------
    // CATEGORY INSIGHTS
    // --------------------

    for (final category in analytics) {
      final name = category['category'];

      final amount = (category['amount'] as num).toDouble();

      final percentage = (category['percentage'] as num).toDouble();

      final comparison = (category['comparisonPercentage'] as num).toDouble();

      // FOOD

      if (name == 'Food') {
        if (percentage >= 35) {
          addInsight(
            emoji: '🍔',
            color: 0xFFFFA500,
            text:
                'Food consumed ${percentage.toStringAsFixed(0)}% of spending.',
          );
        }

        if (comparison >= 50) {
          addInsight(
            emoji: '🍟',
            color: 0xFFFF5C5C,
            text: 'Food spending increased sharply this period.',
          );
        }

        if (comparison <= -30) {
          addInsight(
            emoji: '🥗',
            color: 0xFF00E5B0,
            text: 'Food spending became more efficient.',
          );
        }
      }

      // LOANS

      if (name == 'Loans') {
        if (percentage >= 20) {
          addInsight(
            emoji: '💀',
            color: 0xFFFF5C5C,
            text:
                'Loans consumed ${percentage.toStringAsFixed(0)}% of spending.',
          );
        }

        if (comparison <= -25) {
          addInsight(
            emoji: '📉',
            color: 0xFF00E5B0,
            text: 'Loan burden reduced compared to the previous period.',
          );
        }
      }

      // HEALTH

      if (name == 'Health') {
        if (amount >= 2000 && comparison >= 50) {
          addInsight(
            emoji: '⚕️',
            color: 0xFFFF5C5C,
            text:
                'Health expenses increased significantly. Keep an eye on recurring costs.',
          );
        }

        if (amount >= 2000 && comparison <= -50) {
          addInsight(
            emoji: '🩺',
            color: 0xFF00E5B0,
            text:
                'Health expenses dropped significantly. Hopefully that reflects better health.',
          );
        }
      }

      // SAVINGS

      if (name == 'Savings') {
        if (percentage >= 15) {
          addInsight(
            emoji: '🏦',
            color: 0xFF00E5B0,
            text:
                'Savings captured ${percentage.toStringAsFixed(0)}% of spending.',
          );
        }

        if (comparison >= 50) {
          addInsight(
            emoji: '🚀',
            color: 0xFF00E5B0,
            text: 'Savings grew significantly this period.',
          );
        }
      }

      // TRANSPORT

      if (name == 'Transport') {
        if (comparison <= -30) {
          addInsight(
            emoji: '🚕',
            color: 0xFF00E5B0,
            text: 'Transport costs dropped noticeably.',
          );
        }

        if (comparison >= 40) {
          addInsight(
            emoji: '⛽',
            color: 0xFFFFA500,
            text: 'Transport spending increased this period.',
          );
        }
      }

      // ENTERTAINMENT

      if (name == 'Entertainment') {
        if (comparison >= 100) {
          addInsight(
            emoji: '🎬',
            color: 0xFFFFA500,
            text:
                'Entertainment spending doubled. The memories better be worth it.',
          );
        }
      }

      // TRIPS

      if (name == 'Trips') {
        if (percentage >= 20) {
          addInsight(
            emoji: '✈️',
            color: 0xFF4DA3FF,
            text: 'Travel became a major spending category.',
          );
        }
      }

      // BILLS

      if (name == 'Bills') {
        if (percentage >= 15) {
          addInsight(
            emoji: '📄',
            color: 0xFF4DA3FF,
            text: 'Bills continue to take a meaningful share of spending.',
          );
        }
      }

      // HOUSEHOLD

      if (name == 'Household') {
        if (percentage >= 15) {
          addInsight(
            emoji: '🏠',
            color: 0xFF9B6BFF,
            text: 'Household spending received extra attention this period.',
          );
        }
      }

      // LIFESTYLE

      if (name == 'Lifestyle') {
        if (comparison >= 50) {
          addInsight(
            emoji: '🛍️',
            color: 0xFFFFA500,
            text: 'Lifestyle spending increased noticeably.',
          );
        }
      }

      // INSURANCE

      if (name == 'Insurance') {
        addInsight(
          emoji: '🛡️',
          color: 0xFF00E5B0,
          text: 'Insurance spending strengthens future protection.',
        );
      }
    }

    if (insights.isEmpty) {
      addInsight(
        emoji: '📊',
        color: 0xFF4DA3FF,
        text:
            'Spending remained relatively balanced during the selected period.',
      );
    }

    insights.shuffle();

    return insights;
  }
}
