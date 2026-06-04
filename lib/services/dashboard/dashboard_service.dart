import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  Future<Map<String, dynamic>> getDashboardData(
    DateTime selectedMonth,
    String selectedPerson,
    String workspaceId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    final transactions = snapshot.docs;

    final limitsSnapshot = await FirebaseFirestore.instance
        .collection('expense_limits')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    double balanceIncome = 0;

    double balanceExpense = 0;

    double monthIncome = 0;

    double monthExpense = 0;

    double previousMonthSavings = 0;

    final Map<String, double> categorySpent = {};

    final Map<String, double> categoryLimits = {};

    // =========================
    // PERSON FILTER
    // =========================

    bool matchesPerson(String person) {
      // ALL
      if (selectedPerson == 'All') {
        return true;
      }

      // BOTH ONLY
      if (selectedPerson == 'Both') {
        return person == 'Both';
      }

      // ESWAR / LATHA
      return person == selectedPerson || person == 'Both';
    }

    // =========================
    // PREVIOUS MONTH
    // =========================

    final DateTime previousMonth = DateTime(
      selectedMonth.year,

      selectedMonth.month - 1,
    );

    // =========================
    // LOOP TRANSACTIONS
    // =========================

    for (final doc in transactions) {
      final data = doc.data();

      final String type = data['type'] ?? '';

      double amount = (data['amount'] ?? 0).toDouble();

      final String person = data['person'] ?? '';

      final int month = data['month'] ?? 0;

      final int year = data['year'] ?? 0;

      // =====================
      // PERSON MATCH
      // =====================

      if (!matchesPerson(person)) {
        continue;
      }

      // =====================
      // SPLIT BOTH
      // =====================

      if (selectedPerson != 'All' &&
          selectedPerson != 'Both' &&
          person == 'Both') {
        amount = amount / 2;
      }

      // =====================
      // BALANCE TILL MONTH
      // =====================

      final bool isBeforeOrEqual =
          year < selectedMonth.year ||
          (year == selectedMonth.year && month <= selectedMonth.month);

      if (isBeforeOrEqual) {
        if (type == 'Income') {
          balanceIncome += amount;
        }

        if (type == 'Expense') {
          balanceExpense += amount;
        }
      }

      // =====================
      // SELECTED MONTH
      // =====================

      final bool isSelectedMonth =
          month == selectedMonth.month && year == selectedMonth.year;

      if (isSelectedMonth) {
        // INCOME
        if (type == 'Income') {
          monthIncome += amount;
        }

        // EXPENSE
        if (type == 'Expense') {
          monthExpense += amount;

          categorySpent.putIfAbsent(data['category'], () => 0);

          categorySpent[data['category']] =
              categorySpent[data['category']]! + amount;
        }
      }

      // =====================
      // PREVIOUS MONTH
      // =====================

      final bool isPreviousMonth =
          month == previousMonth.month && year == previousMonth.year;

      if (isPreviousMonth) {
        if (type == 'Income') {
          previousMonthSavings += amount;
        }

        if (type == 'Expense') {
          previousMonthSavings -= amount;
        }
      }
    }

    // =========================
    // EXPENSE LIMITS
    // =========================

    for (final doc in limitsSnapshot.docs) {
      final data = doc.data();

      final String category = data['category'];

      final String person = data['person'];

      double limit = (data['limit'] ?? 0).toDouble();

      // =====================
      // ALL
      // =====================

      if (selectedPerson == 'All') {
        categoryLimits.putIfAbsent(category, () => 0);

        categoryLimits[category] = categoryLimits[category]! + limit;

        continue;
      }

      // =====================
      // BOTH ONLY
      // =====================

      if (selectedPerson == 'Both') {
        if (person != 'Both') {
          continue;
        }

        categoryLimits.putIfAbsent(category, () => 0);

        categoryLimits[category] = categoryLimits[category]! + limit;

        continue;
      }

      // =====================
      // ESWAR / LATHA
      // =====================

      if (person == selectedPerson) {
        categoryLimits.putIfAbsent(category, () => 0);

        categoryLimits[category] = categoryLimits[category]! + limit;
      }

      // HALF BOTH LIMIT
      if (person == 'Both') {
        categoryLimits.putIfAbsent(category, () => 0);

        categoryLimits[category] = categoryLimits[category]! + (limit / 2);
      }
    }

    // =========================
    // BUILD LIMITS
    // =========================

    final List<Map<String, dynamic>> expenseLimits = [];

    for (final category in categoryLimits.keys) {
      expenseLimits.add({
        'category': category,

        'spent': categorySpent[category] ?? 0,

        'limit': categoryLimits[category] ?? 0,
      });
    }

    // =========================
    // TOP CATEGORIES
    // =========================

    final topCategories = categorySpent.entries.toList()
      ..sort((a, b) {
        return b.value.compareTo(a.value);
      });

    // =========================
    // SAVINGS
    // =========================

    final double savings = monthIncome - monthExpense;

    // =========================
    // BALANCE
    // =========================

    final double balance = balanceIncome - balanceExpense;

    // =========================
    // PERCENTAGE CHANGE
    // =========================

    double percentageChange = 0;

    if (previousMonthSavings != 0) {
      percentageChange =
          ((savings - previousMonthSavings) / previousMonthSavings.abs()) * 100;
    }

    // =========================
    // RETURN
    // =========================

    return {
      'balance': balance,

      'income': monthIncome,

      'expense': monthExpense,

      'savings': savings,

      'percentageChange': percentageChange,

      'expenseLimits': expenseLimits,

      'topCategories': topCategories.take(5).toList(),
    };
  }
}
