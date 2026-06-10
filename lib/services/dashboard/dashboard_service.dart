import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/services/loan_calculation_service.dart';

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

    final Map<String, double> detailSpent = {};

    // =========================
    // PERSON FILTER
    // =========================

    bool matchesPerson(String person) {
      // ALL
      if (selectedPerson == 'All') {
        return true;
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

          final detailId = data['detailId'] ?? '';

          detailSpent.putIfAbsent(detailId, () => 0);

          detailSpent[detailId] = detailSpent[detailId]! + amount;

          // =====================
          // TOP CATEGORIES
          // =====================

          final category = data['category'] ?? '';

          categorySpent.putIfAbsent(category, () => 0);

          categorySpent[category] = categorySpent[category]! + amount;
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

    // =========================
    // EXPENSE LIMITS
    // =========================

    final List<Map<String, dynamic>> expenseLimits = [];

    for (final limitDoc in limitsSnapshot.docs) {
      final limitData = limitDoc.data();

      final String limitPerson = limitData['person'] ?? '';

      final String detail = limitData['detail'] ?? '';

      final String detailId = limitData['detailId'] ?? '';

      final double limit = (limitData['limit'] ?? 0).toDouble();

      // Ignore Both limits
      if (limitPerson == 'Both') {
        continue;
      }

      // =====================
      // ALL
      // =====================

      if (selectedPerson == 'All') {
        double spent = 0;

        for (final transactionDoc in transactions) {
          final tx = transactionDoc.data();

          if ((tx['detailId'] ?? '') != detailId) {
            continue;
          }

          if ((tx['type'] ?? '') != 'Expense') {
            continue;
          }

          final int month = tx['month'] ?? 0;

          final int year = tx['year'] ?? 0;

          if (month != selectedMonth.month || year != selectedMonth.year) {
            continue;
          }

          final String txPerson = tx['person'] ?? '';

          final double amount = (tx['amount'] ?? 0).toDouble();

          if (txPerson == limitPerson) {
            spent += amount;
          }

          if (txPerson == 'Both') {
            spent += amount / 2;
          }
        }

        expenseLimits.add({
          'person': limitPerson,
          'detail': detail,
          'detailId': detailId,
          'spent': spent,
          'limit': limit,
        });

        continue;
      }

      // =====================
      // INDIVIDUAL PERSON
      // =====================

      if (limitPerson != selectedPerson) {
        continue;
      }

      double spent = 0;

      for (final transactionDoc in transactions) {
        final tx = transactionDoc.data();

        if ((tx['detailId'] ?? '') != detailId) {
          continue;
        }

        if ((tx['type'] ?? '') != 'Expense') {
          continue;
        }

        final int month = tx['month'] ?? 0;

        final int year = tx['year'] ?? 0;

        if (month != selectedMonth.month || year != selectedMonth.year) {
          continue;
        }

        final String txPerson = tx['person'] ?? '';

        final double amount = (tx['amount'] ?? 0).toDouble();

        if (txPerson == selectedPerson) {
          spent += amount;
        }

        if (txPerson == 'Both') {
          spent += amount / 2;
        }
      }

      expenseLimits.add({
        'person': limitPerson,
        'detail': detail,
        'detailId': detailId,
        'spent': spent,
        'limit': limit,
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
    final loanData = await LoanCalculationService().calculateLoans(
      selectedMonth: selectedMonth,
    );
    return {
      'balance': balance,

      'income': monthIncome,

      'expense': monthExpense,

      'savings': savings,

      'percentageChange': percentageChange,
      'expenseLimits': expenseLimits,
      'topCategories': topCategories.take(5).toList(),
      'loanOutstanding': loanData['totalOutstanding'] ?? 0,
    };
  }
}
