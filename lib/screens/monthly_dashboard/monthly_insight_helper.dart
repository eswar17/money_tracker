class MonthlyInsightHelper {

  // =========================
  // NO SPEND DAYS
  // =========================

  static int getNoSpendDays(

    Set<int> expenseDays,
  ) {

    return

        30 -
            expenseDays.length;
  }

  // =========================
  // MOST EXPENSIVE DAY
  // =========================

  static Map<String, dynamic>
      getMostExpensiveDay(

    Map<String, double>
        dayExpenses,
  ) {

    if (dayExpenses.isEmpty) {

      return {

        'day': '-',

        'amount': 0.0,
      };
    }

    final highest =

        dayExpenses.entries
            .reduce(

      (a, b) {

        return a.value >
                b.value

            ? a
            : b;
      },
    );

    return {

      'day': highest.key,

      'amount':
          highest.value,
    };
  }

  // =========================
  // CATEGORY DOMINATION
  // =========================

  static String
      getCategoryDomination(

    Map<String, double>
        categories,

    double totalExpense,
  ) {

    if (categories.isEmpty) {

      return
          '😎 Balanced spending';
    }

    final highest =

        categories.entries
            .reduce(

      (a, b) {

        return a.value >
                b.value

            ? a
            : b;
      },
    );

    final percent =

        totalExpense == 0

            ? 0

            : (highest.value /
                    totalExpense) *
                100;

    final category =
        highest.key;

    if (

    category ==
            'Food' &&

        percent > 30

    ) {

      return

          '🍔 Swiggy CEO of the Month\nFood consumed ${percent.toStringAsFixed(0)}% of all expenses';
    }

    return

        '📊 $category consumed ${percent.toStringAsFixed(0)}% of all expenses';
  }

  // =========================
  // SAVINGS TITLE
  // =========================

  static String
      getSavingsTitle(

    double savingsRate,
  ) {

    if (savingsRate >= 70) {

      return
          '🧘 Finance Monk';
    }

    if (savingsRate >= 50) {

      return
          '📈 Smart Saver';
    }

    if (savingsRate >= 30) {

      return
          '👍 Balanced';
    }

    if (savingsRate >= 10) {

      return
          '😬 Risk Zone';
    }

    return
        '💀 Bankruptcy Energy';
  }

  // =========================
  // FINANCIAL MOOD
  // =========================

  static String
      getFinancialMood(

    Map<String, double>
        categories,
  ) {

    if (categories.isEmpty) {

      return
          '😴 Silent Month';
    }

    final highest =

        categories.entries
            .reduce(

      (a, b) {

        return a.value >
                b.value

            ? a
            : b;
      },
    );

    switch (highest.key) {

      case 'Food':

        return
            '🍔 Cheat Month';

      case 'Health':

        return
            '💊 Recovery Mode';

      case 'Entertainment':

        return
            '🎬 Fun Mode';

      case 'Trips':

        return
            '✈️ Adventure Month';

      default:

        return
            '😎 Balanced Lifestyle';
    }
  }

  // =========================
  // SPENDING STREAK
  // =========================

  static int
      getSpendingStreak(

    List<int> expenseDays,
  ) {

    if (expenseDays.isEmpty) {

      return 0;
    }

    expenseDays.sort();

    int streak = 1;

    int maxStreak = 1;

    for (

      int i = 1;

      i < expenseDays.length;

      i++
    ) {

      if (

      expenseDays[i] ==

          expenseDays[i - 1] + 1

      ) {

        streak++;

      } else {

        streak = 1;
      }

      if (streak >
          maxStreak) {

        maxStreak = streak;
      }
    }

    return maxStreak;
  }

  // =========================
  // CREDIT CARD PRESSURE
  // =========================

  static String
      getCreditCardPressure(

    double creditSpent,

    double totalExpense,
  ) {

    final percent =

        totalExpense == 0

            ? 0

            : (creditSpent /
                    totalExpense) *
                100;

    if (percent >= 70) {

      return
          '⚠️ Heavy Credit Usage Month';
    }

    if (percent >= 40) {

      return
          '💳 Moderate Credit Dependency';
    }

    return
        '✅ Healthy Credit Usage';
  }

  // =========================
  // ACHIEVEMENTS
  // =========================

  static List<String>
      getAchievements({

    required double savings,

    required int noSpendDays,

    required double savingsRate,
  }) {

    final List<String>
        achievements = [];

    if (savings >= 100000) {

      achievements.add(
        '🏆 ₹1L Savings Month',
      );
    }

    if (noSpendDays >= 10) {

      achievements.add(
        '🧘 Discipline Master',
      );
    }

    if (savingsRate >= 50) {

      achievements.add(
        '📈 Elite Saver',
      );
    }

    return achievements;
  }

  // =========================
  // MONTH COMPARISON
  // =========================

  static String
      getMonthComparison({

    required double currentExpense,

    required double previousExpense,
  }) {

    if (previousExpense == 0) {

      return
          '📊 No previous data';
    }

    final percent =

        ((currentExpense -
                        previousExpense) /
                    previousExpense) *
                100;

    if (percent > 0) {

      return

          '⬆ Expenses increased by ${percent.toStringAsFixed(0)}%';
    }

    return

        '⬇ Expenses reduced by ${percent.abs().toStringAsFixed(0)}%';
  }

  // =========================
  // SMART WARNINGS
  // =========================

  static List<String>
      getWarnings({

    required double savingsRate,

    required double foodPercent,
  }) {

    final warnings =
        <String>[];

    if (foodPercent >= 35) {

      warnings.add(

        '⚠️ Food spending too high',
      );
    }

    if (savingsRate <= 10) {

      warnings.add(

        '⚠️ Savings critically low',
      );
    }

    return warnings;
  }
}