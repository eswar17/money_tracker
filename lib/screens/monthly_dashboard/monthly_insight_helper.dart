class MonthlyInsightHelper {
  // =========================
  // NO SPEND DAYS
  // =========================

  static int getNoSpendDays(Set<int> expenseDays) {
    return 30 - expenseDays.length;
  }

  // =========================
  // MOST EXPENSIVE DAY
  // =========================

  static Map<String, dynamic> getMostExpensiveDay(
    Map<String, double> dayExpenses,
  ) {
    if (dayExpenses.isEmpty) {
      return {'day': '-', 'amount': 0.0};
    }

    final highest = dayExpenses.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    });

    return {'day': highest.key, 'amount': highest.value};
  }

  // =========================
  // CATEGORY DOMINATION
  // =========================

  static String getCategoryDomination(
    Map<String, double> categories,

    double totalExpense,
  ) {
    if (categories.isEmpty) {
      return '😎 Balanced spending';
    }

    final highest = categories.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    });

    final percent = totalExpense == 0
        ? 0
        : (highest.value / totalExpense) * 100;

    final category = highest.key;

    if (category == 'Food' && percent > 30) {
      return '🍔 Swiggy CEO of the Month\nFood consumed ${percent.toStringAsFixed(0)}% of all expenses';
    }

    return '📊 $category consumed ${percent.toStringAsFixed(0)}% of all expenses';
  }

  // =========================
  // SAVINGS TITLE
  // =========================

  static String getSavingsTitle(double savingsRate) {
    if (savingsRate >= 70) {
      return '🧘 Finance Monk';
    }

    if (savingsRate >= 50) {
      return '📈 Smart Saver';
    }

    if (savingsRate >= 30) {
      return '👍 Balanced';
    }

    if (savingsRate >= 10) {
      return '😬 Risk Zone';
    }

    return '💀 Bankruptcy Energy';
  }

  static String getFunInsight(Map<String, double> details) {
    // =====================
    // TAG SCORES
    // =====================

    final Map<String, int> tags = {};

    void addTags(List<String> values) {
      for (final tag in values) {
        tags[tag] = (tags[tag] ?? 0) + 1;
      }
    }

    // =====================
    // LIMIT CHECKS
    // =====================

    final bool junkFood = (details['Junk Food'] ?? 0) > 750;

    final bool dining =
        ((details['Dining'] ?? 0) + (details['Food Order'] ?? 0)) > 2500;

    final bool fashion =
        ((details['Clothes'] ?? 0) + (details['Shoes'] ?? 0)) > 2500;

    final bool grooming = (details['Grooming'] ?? 0) > 2500;

    final bool accessories = (details['Accessories'] ?? 0) > 2500;

    final bool movies = (details['Movies'] ?? 0) > 500;

    final bool gifts = (details['Gifts'] ?? 0) > 1500;

    final bool misc = (details['Miscellaneous'] ?? 0) > 1500;

    final bool ott = (details['OTT'] ?? 0) > 500;

    final bool apps = (details['Apps'] ?? 0) > 300;

    final bool trips =
        ((details['Hotel'] ?? 0) + (details['Transport'] ?? 0)) > 6000;

    // =====================
    // TAG ASSIGNMENT
    // =====================

    if (junkFood) {
      addTags(['food', 'dopamine', 'impulse']);
    }

    if (dining) {
      addTags(['food', 'luxury', 'social']);
    }

    if (fashion) {
      addTags(['shopping', 'lifestyle', 'luxury']);
    }

    if (grooming) {
      addTags(['confidence', 'selfcare', 'lifestyle']);
    }

    if (accessories) {
      addTags(['shopping', 'luxury', 'lifestyle']);
    }

    if (movies) {
      addTags(['entertainment', 'dopamine', 'weekend']);
    }

    if (gifts) {
      addTags(['celebration', 'social', 'emotional']);
    }

    if (misc) {
      addTags(['chaos', 'impulse', 'unplanned']);
    }

    if (ott) {
      addTags(['entertainment', 'binge', 'comfort']);
    }

    if (apps) {
      addTags(['digital', 'subscriptions', 'convenience']);
    }

    if (trips) {
      addTags(['travel', 'luxury', 'experience']);
    }

    // =====================
    // SCORES
    // =====================

    final int food = tags['food'] ?? 0;

    final int dopamine = tags['dopamine'] ?? 0;

    final int luxury = tags['luxury'] ?? 0;

    final int entertainment = tags['entertainment'] ?? 0;

    final int lifestyle = tags['lifestyle'] ?? 0;

    final int shopping = tags['shopping'] ?? 0;

    final int impulse = tags['impulse'] ?? 0;

    final int social = tags['social'] ?? 0;

    final int chaos = tags['chaos'] ?? 0;

    final int confidence = tags['confidence'] ?? 0;

    final int travel = tags['travel'] ?? 0;

    final int emotional = tags['emotional'] ?? 0;

    // =====================
    // GOD TIER INSIGHTS
    // =====================

    if (food >= 2 && dopamine >= 2) {
      return 'Sponsored by Swiggy & Zomato';
    }

    if (luxury >= 3 && lifestyle >= 2) {
      return 'Rich in Vibes, Poor in Balance';
    }

    if (luxury >= 2 && lifestyle >= 3) {
      return 'Emotional Damage Purchases';
    }

    if (confidence >= 1 && lifestyle >= 2) {
      return 'Mirror Confidence Investments';
    }

    if (entertainment >= 2 && dopamine >= 1) {
      return 'OTT Investor of the Month';
    }

    if (impulse >= 2 && chaos >= 1) {
      return 'UPI Tap Tap Disaster';
    }

    // =====================
    // HIGH TIER INSIGHTS
    // =====================

    if (luxury >= 2 && food >= 1) {
      return 'Zomato Gold & Zara Combo Pack';
    }

    if (emotional >= 1 && social >= 1) {
      return 'Emotional Damage Purchases';
    }

    if (travel >= 1 && food >= 1) {
      return 'Vacation Calories Package';
    }

    if (food >= 2) {
      return 'Swiggy CEO of the Month';
    }

    if (entertainment >= 2) {
      return 'Subscription Based Personality';
    }

    if (shopping >= 2 && luxury >= 2) {
      return 'Lifestyle Inflation Starter Pack';
    }

    if (confidence >= 1 && luxury >= 1) {
      return '✨ Main Character Energy';
    }

    if (dopamine >= 2 && entertainment >= 1) {
      return 'Netflix & Nuggets Lifestyle';
    }

    if (entertainment >= 1 && food >= 1) {
      return 'Weekend Wallet Destroyer';
    }

    if (chaos >= 1 && entertainment >= 1) {
      return '“It’s just 200” Simulator';
    }

    if (social >= 1 && luxury >= 1) {
      return 'Celebration Budget Gone Missing';
    }

    if (chaos >= 1 && shopping >= 1) {
      return 'Cart Therapy Session';
    }

    if (travel >= 1 && luxury >= 1) {
      return 'Airport Spending Addiction';
    }

    // =====================
    // SINGLE CATEGORY
    // =====================

    if (food >= 1) {
      return 'Junk Food Arc Activated';
    }

    if (luxury >= 1) {
      return 'Lifestyle Spending Entered the Chat';
    }

    if (confidence >= 1) {
      return 'Self-Care Spending Era';
    }

    if (entertainment >= 1) {
      return 'Cinema Lifestyle Activated';
    }

    if (shopping >= 1) {
      return 'Fashion Finance Collapsed';
    }

    if (social >= 1) {
      return 'Gift Giving Side Quest';
    }

    if (chaos >= 1) {
      return 'Mystery Expenses Entered the Chat';
    }

    if (travel >= 1) {
      return 'Travel Arc Unlocked';
    }

    // =====================
    // DEFAULT
    // =====================

    return 'NPC Spending Month';
  }

  // =========================
  // FINANCIAL MOOD
  // =========================

  static String getFinancialMood(Map<String, double> categories) {
    if (categories.isEmpty) {
      return '😴 Silent Month';
    }

    final highest = categories.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    });

    switch (highest.key) {
      case 'Food':
        return '🍔 Cheat Month';

      case 'Transport':
        return '🚕 Travel Heavy Month';

      case 'Health':
        return '💊 Recovery Mode';

      case 'Household':
        return '🏠 Adulting Survival Month';

      case 'Bills':
        return '📄 Bill Paying Simulator';

      case 'Lifestyle':
        return '🛍 Lifestyle Inflation Era';

      case 'Entertainment':
        return '🎬 Fun Mode Activated';

      case 'Subscriptions':
        return '📺 Subscription Trap Month';

      case 'Savings':
        return '📈 Finance Monk';

      case 'Charity':
        return '🙏 Generous Soul Month';

      case 'Gifts':
        return '🎁 Celebration Season';

      case 'Trips':
        return '✈️ Adventure Month';

      case 'Loans':
        return '💀 Debt Pressure Month';

      case 'Insurance':
        return '🛡 Protection Priority Month';

      default:
        return '😎 Balanced Lifestyle';
    }
  }

  // =========================
  // SPENDING STREAK
  // =========================

  static int getSpendingStreak(List<int> expenseDays) {
    if (expenseDays.isEmpty) {
      return 0;
    }

    expenseDays.sort();

    int streak = 1;

    int maxStreak = 1;

    for (int i = 1; i < expenseDays.length; i++) {
      if (expenseDays[i] == expenseDays[i - 1] + 1) {
        streak++;
      } else {
        streak = 1;
      }

      if (streak > maxStreak) {
        maxStreak = streak;
      }
    }

    return maxStreak;
  }

  // =========================
  // CREDIT CARD PRESSURE
  // =========================

  static String getCreditCardPressure(double creditSpent, double totalExpense) {
    final percent = totalExpense == 0 ? 0 : (creditSpent / totalExpense) * 100;

    if (percent >= 70) {
      return '⚠️ Heavy Credit Usage Month';
    }

    if (percent >= 40) {
      return '💳 Moderate Credit Dependency';
    }

    return '✅ Healthy Credit Usage';
  }

  // =========================
  // ACHIEVEMENTS
  // =========================

  static List<String> getAchievements({
    required double savings,

    required int noSpendDays,

    required double savingsRate,
  }) {
    final List<String> achievements = [];

    if (savings >= 100000) {
      achievements.add('🏆 ₹1L Savings Month');
    }

    if (noSpendDays >= 10) {
      achievements.add('🧘 Discipline Master');
    }

    if (savingsRate >= 50) {
      achievements.add('📈 Elite Saver');
    }

    return achievements;
  }

  // =========================
  // MONTH COMPARISON
  // =========================

  static String getMonthComparison({
    required double currentExpense,

    required double previousExpense,
  }) {
    if (previousExpense == 0) {
      return '📊 No previous data';
    }

    final percent =
        ((currentExpense - previousExpense) / previousExpense) * 100;

    if (percent > 0) {
      return '⬆ Expenses increased by ${percent.toStringAsFixed(0)}%';
    }

    return '⬇ Expenses reduced by ${percent.abs().toStringAsFixed(0)}%';
  }

  // =========================
  // SMART WARNINGS
  // =========================

  static List<String> getWarnings({
    required double savingsRate,

    required double foodPercent,
  }) {
    final warnings = <String>[];

    if (foodPercent >= 35) {
      warnings.add('⚠️ Food spending too high');
    }

    if (savingsRate <= 10) {
      warnings.add('⚠️ Savings critically low');
    }

    return warnings;
  }
}
