import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/models/loan_config_model.dart';

import './workspace/workspace_context.dart';

class LoanCalculationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> calculateLoans() async {
    final workspaceId = WorkspaceContext.currentWorkspaceId!;

    final transactionsSnapshot = await firestore
        .collection('transactions')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    final configsSnapshot = await firestore
        .collection('loan_configs')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    final transactions = transactionsSnapshot.docs;

    final configs = configsSnapshot.docs;

    final Map<String, LoanConfigModel> configMap = {};

    for (final doc in configs) {
      final model = LoanConfigModel.fromMap(doc.data(), doc.id);

      configMap[model.detailName] = model;
    }

    final Map<String, double> borrowedMap = {};

    final Map<String, double> repaidMap = {};

    // =====================================
    // TRANSACTION ANALYSIS
    // =====================================

    final emiDetails = configMap.values
        .where((e) => e.loanType == 'emiPurchase')
        .map((e) => e.detailName)
        .toSet();

    for (final doc in transactions) {
      final data = doc.data();

      final category = (data['category'] ?? '').toString();

      final detail = (data['detail'] ?? '').toString();

      final type = (data['type'] ?? '').toString();

      final amount = (data['amount'] ?? 0).toDouble();
      final isLoanCategory =
          category.toLowerCase() == 'loan' || category.toLowerCase() == 'loans';

      final isEmiCategory = category.toLowerCase() == 'emi';

      if (!isLoanCategory && !isEmiCategory) {
        continue;
      }
      // Only Loan Category
      // if (category.toLowerCase() != 'loan' &&
      //     category.toLowerCase() != 'loans') {
      //   continue;
      // }

      // EMI
      if (emiDetails.contains(detail)) {
        repaidMap.putIfAbsent(detail, () => 0);

        if (type == 'Expense') {
          repaidMap[detail] = repaidMap[detail]! + amount;
        }

        continue;
      }

      // BANK / FRIEND
      borrowedMap.putIfAbsent(detail, () => 0);

      repaidMap.putIfAbsent(detail, () => 0);

      if (type == 'Income') {
        borrowedMap[detail] = borrowedMap[detail]! + amount;
      }

      if (type == 'Expense') {
        repaidMap[detail] = repaidMap[detail]! + amount;
      }
    }

    // =====================================
    // BUILD LOANS
    // =====================================

    final allLoanDetails = {
      ...borrowedMap.keys,
      ...repaidMap.keys,
      ...configMap.keys,
    };

    final List<Map<String, dynamic>> loans = [];

    double totalOutstanding = 0;

    double bankOutstanding = 0;

    double friendOutstanding = 0;

    double emiOutstanding = 0;

    for (final detailName in allLoanDetails) {
      final config = configMap[detailName];

      final borrowed = borrowedMap[detailName] ?? 0;

      final repaid = repaidMap[detailName] ?? 0;

      final loanType = config?.loanType ?? 'friendLoan';

      final loanName = config?.loanName ?? detailName;

      double outstanding = 0;

      // ==========================
      // EMI PURCHASE
      // ==========================

      if (loanType == 'emiPurchase') {
        final totalAmount = config?.totalAmount ?? 0;

        outstanding = totalAmount - repaid;
      }
      // ==========================
      // BANK / FRIEND
      // ==========================
      else {
        outstanding = borrowed - repaid;
      }

      if (outstanding < 0) {
        outstanding = 0;
      }

      totalOutstanding += outstanding;

      switch (loanType) {
        case 'bankLoan':
          bankOutstanding += outstanding;
          break;

        case 'friendLoan':
          friendOutstanding += outstanding;
          break;

        case 'emiPurchase':
          emiOutstanding += outstanding;
          break;
      }

      // ==========================
      // EMI MONTHS LEFT
      // ==========================

      int? monthsLeft;

      if (loanType == 'emiPurchase') {
        final totalAmount = config?.totalAmount ?? 0;

        outstanding = totalAmount - repaid;
      }

      loans.add({
        'loanName': loanName,

        'detailName': detailName,

        'loanType': loanType,

        'borrowed': borrowed,

        'repaid': repaid,

        'outstanding': outstanding,

        'totalAmount': config?.totalAmount ?? borrowed,

        'emiAmount': config?.emiAmount ?? 0,

        'dueDay': config?.dueDay,

        'monthsLeft': monthsLeft,

        'notes': config?.notes ?? '',

        'reminderEnabled': config?.reminderEnabled ?? false,

        'config': config,
      });
    }

    loans.sort((a, b) {
      return (b['outstanding'] as double).compareTo(a['outstanding'] as double);
    });

    return {
      'totalOutstanding': totalOutstanding,

      'bankOutstanding': bankOutstanding,

      'friendOutstanding': friendOutstanding,

      'emiOutstanding': emiOutstanding,

      'loans': loans,
    };
  }
}
