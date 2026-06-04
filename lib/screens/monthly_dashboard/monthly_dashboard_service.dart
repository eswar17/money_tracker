import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';

import 'monthly_insight_helper.dart';

class MonthlyDashboardService {
  Future<Map<String, dynamic>> getMonthlyData(
    DateTime selectedMonth,

    String selectedType,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    // =========================
    // SUMMARY
    // =========================

    double income = 0;

    double expense = 0;

    double transfer = 0;

    // =========================
    // PERSON SPENDING
    // =========================

    final Map<String, double> personSpent = {};

    // =========================
    // ACCOUNT ANALYSIS
    // =========================

    final Map<String, double> accountSpent = {};

    // =========================
    // CATEGORY ANALYSIS
    // =========================

    final Map<String, double> categoryData = {};

    final Map<String, double> detailCategories = {};

    final Map<String, double> expenseCategories = {};

    // =========================
    // DAY ANALYSIS
    // =========================

    final Map<String, double> dayExpenses = {};

    final Set<int> expenseDays = {};

    // =========================
    // CREDIT CARD ANALYSIS
    // =========================

    double creditCardSpent = 0;

    // =========================
    // PREVIOUS MONTH
    // =========================

    double previousMonthExpense = 0;

    // =========================
    // LOOP
    // =========================

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final int month = data['month'] ?? 0;

      final int year = data['year'] ?? 0;

      final String type = data['type'] ?? '';

      final String category = data['category'] ?? '';

      final String person = data['person'] ?? '';

      final String paymentMethod = data['paymentMethod'] ?? '';

      final double amount = (data['amount'] ?? 0).toDouble();

      // =====================
      // PREVIOUS MONTH
      // =====================

      final previousMonth = DateTime(
        selectedMonth.year,

        selectedMonth.month - 1,
      );

      if (month == previousMonth.month &&
          year == previousMonth.year &&
          type == 'Expense') {
        previousMonthExpense += amount;
      }

      // =====================
      // FILTER CURRENT MONTH
      // =====================

      if (month != selectedMonth.month || year != selectedMonth.year) {
        continue;
      }

      // =====================
      // SUMMARY
      // =====================

      if (type == 'Income') {
        income += amount;
      }

      if (type == 'Expense') {
        expense += amount;
      }

      if (type == 'Transfer') {
        transfer += amount;
      }

      // =====================
      // PERSON ANALYSIS
      // =====================

      if (type == 'Expense') {
        personSpent.update(
          person,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }

      // =====================
      // ACCOUNT ANALYSIS
      // =====================

      accountSpent.putIfAbsent(paymentMethod, () => 0);

      accountSpent[paymentMethod] = accountSpent[paymentMethod]! + amount;

      // =====================
      // CATEGORY BREAKDOWN
      // =====================

      if (type == selectedType) {
        categoryData.putIfAbsent(category, () => 0);

        categoryData[category] = categoryData[category]! + amount;
      }

      // =====================
      // EXPENSE CATEGORY
      // =====================

      if (type == 'Expense') {
        final String detail = data['detail'] ?? '';

        expenseCategories.putIfAbsent(category, () => 0);

        expenseCategories[category] = expenseCategories[category]! + amount;

        detailCategories.putIfAbsent(detail, () => 0);

        detailCategories[detail] = detailCategories[detail]! + amount;
      }

      // =====================
      // MOST EXPENSIVE DAY
      // =====================

      if (type == 'Expense') {
        final String dayKey =
            '${data['date'].toDate().day}/${data['date'].toDate().month}';

        expenseDays.add(data['date'].toDate().day);

        dayExpenses.putIfAbsent(dayKey, () => 0);

        dayExpenses[dayKey] = dayExpenses[dayKey]! + amount;
      }

      // =====================
      // CREDIT CARD
      // =====================

      if (paymentMethod.toLowerCase().contains('credit') && type == 'Expense') {
        creditCardSpent += amount;
      }
    }

    // =========================
    // SAVINGS
    // =========================

    final double savings = income - expense;

    final double savingsRate = income == 0 ? 0 : (savings / income) * 100;

    // =========================
    // INSIGHTS
    // =========================

    final int noSpendDays = MonthlyInsightHelper.getNoSpendDays(expenseDays);

    final expensiveDay = MonthlyInsightHelper.getMostExpensiveDay(dayExpenses);

    final categoryDomination = MonthlyInsightHelper.getCategoryDomination(
      expenseCategories,

      expense,
    );

    final savingsTitle = MonthlyInsightHelper.getSavingsTitle(savingsRate);

    final financialMood = MonthlyInsightHelper.getFinancialMood(
      expenseCategories,
    );

    final funInsight = MonthlyInsightHelper.getFunInsight(expenseCategories);

    final spendingStreak = MonthlyInsightHelper.getSpendingStreak(
      expenseDays.toList(),
    );

    final creditCardPressure = MonthlyInsightHelper.getCreditCardPressure(
      creditCardSpent,

      expense,
    );

    final achievements = MonthlyInsightHelper.getAchievements(
      savings: savings,

      noSpendDays: noSpendDays,

      savingsRate: savingsRate,
    );

    final monthComparison = MonthlyInsightHelper.getMonthComparison(
      currentExpense: expense,

      previousExpense: previousMonthExpense,
    );

    final double foodPercent = expense == 0
        ? 0
        : ((expenseCategories['Food'] ?? 0) / expense) * 100;

    final warnings = MonthlyInsightHelper.getWarnings(
      savingsRate: savingsRate,

      foodPercent: foodPercent,
    );

    // =========================
    // RETURN
    // =========================

    return {
      // SUMMARY
      'income': income,

      'expense': expense,

      'transfer': transfer,

      'savings': savings,

      'savingsRate': savingsRate,

      // PERSON
      'personSpent': personSpent,

      // ACCOUNTS
      'accounts': accountSpent.entries.toList(),

      // CATEGORY
      'categories': categoryData.entries.toList(),

      // INSIGHTS
      'noSpendDays': noSpendDays,

      'mostExpensiveDay': expensiveDay,

      'categoryDomination': categoryDomination,

      'savingsTitle': savingsTitle,

      'financialMood': financialMood,

      'spendingStreak': spendingStreak,

      'creditCardPressure': creditCardPressure,

      'achievements': achievements,

      'monthComparison': monthComparison,

      'warnings': warnings,

      'funInsight': MonthlyInsightHelper.getFunInsight(detailCategories),

      'isHealthy': savings >= 0,
    };
  }
}
