import '../../models/report/grouped_category_report.dart';
import '../../models/report/grouped_report_row.dart';
import '../../models/transaction_model.dart';

class GroupedReportService {
  List<GroupedCategoryReport> build(
    List<TransactionModel> transactions,
    List<TransactionModel> allTransactions,
  ) {
    // =====================================================
    // CATEGORY -> DETAIL -> TAG -> TRANSACTIONS
    // =====================================================

    final Map<String, Map<String, Map<String, List<TransactionModel>>>>
    grouped = {};

    // =====================================================
    // GROUP ONLY EXPENSES
    // =====================================================

    for (final tx in transactions) {
      if (tx.type != 'Expense') {
        continue;
      }

      grouped.putIfAbsent(tx.category, () => {});

      grouped[tx.category]!.putIfAbsent(tx.detail, () => {});

      final String tag = tx.tag.trim().isEmpty ? '—' : tx.tag.trim();

      grouped[tx.category]![tx.detail]!.putIfAbsent(tag, () => []);

      grouped[tx.category]![tx.detail]![tag]!.add(tx);
    }

    // =====================================================
    // BUILD REPORT
    // =====================================================

    final List<GroupedCategoryReport> report = [];

    for (final categoryEntry in grouped.entries) {
      final List<GroupedReportRow> rows = [];

      for (final detailEntry in categoryEntry.value.entries) {
        for (final tagEntry in detailEntry.value.entries) {
          final List<TransactionModel> expenseTransactions = tagEntry.value;

          final double settlement = _calculateSettlement(
            expenseTransactions: expenseTransactions,
            allTransactions: allTransactions,
          );

          rows.add(
            GroupedReportRow(
              detail: detailEntry.key,
              tag: tagEntry.key,
              transactions: expenseTransactions,
              settlement: settlement,
            ),
          );
        }
      }

      // Highest expense first
      rows.sort((a, b) => b.expense.compareTo(a.expense));

      report.add(
        GroupedCategoryReport(category: categoryEntry.key, rows: rows),
      );
    }

    // Highest category expense first
    report.sort((a, b) => b.expense.compareTo(a.expense));

    return report;
  }

  // =====================================================
  // CALCULATE CONSOLIDATED SETTLEMENT
  // =====================================================

  double _calculateSettlement({
    required List<TransactionModel> expenseTransactions,
    required List<TransactionModel> allTransactions,
  }) {
    // -----------------------------------------------------
    // Collect all unique settlement keywords from
    // every expense transaction in this row.
    // -----------------------------------------------------

    final Set<String> settlementKeys = {};

    for (final expense in expenseTransactions) {
      final List<String> keys = _getSettlementKeys(expense.notes);

      settlementKeys.addAll(keys);
    }

    // No settlement attached to this expense row.
    if (settlementKeys.isEmpty) {
      return 0;
    }

    // -----------------------------------------------------
    // All transactions in this row have the same detail
    // because grouping is Category -> Detail -> Tag.
    // -----------------------------------------------------

    final String detail = expenseTransactions.first.detail.trim().toLowerCase();

    double settlementTotal = 0;

    // -----------------------------------------------------
    // Find matching Settlement income transactions.
    // -----------------------------------------------------

    for (final tx in allTransactions) {
      // Settlement is recorded as Income.
      if (tx.type != 'Income') {
        continue;
      }

      // Settlement category only.
      if (tx.category.trim().toLowerCase() != 'settlement') {
        continue;
      }

      // Settlement must have the same detail.
      if (tx.detail.trim().toLowerCase() != detail) {
        continue;
      }

      // Get settlement keywords from this income record.
      final List<String> transactionKeys = _getSettlementKeys(tx.notes);

      if (transactionKeys.isEmpty) {
        continue;
      }

      // If any keyword matches the expense row,
      // include the complete settlement amount.
      final bool matches = transactionKeys.any(
        (key) => settlementKeys.contains(key),
      );

      if (!matches) {
        continue;
      }

      settlementTotal += tx.amount;
    }

    return settlementTotal;
  }

  // =====================================================
  // EXTRACT SETTLEMENT KEYWORDS
  // =====================================================

  List<String> _getSettlementKeys(String notes) {
    if (notes.trim().isEmpty) {
      return [];
    }

    final RegExp regex = RegExp(r'#settlement:([^,\n]+)', caseSensitive: false);

    final Iterable<RegExpMatch> matches = regex.allMatches(notes);

    final Set<String> keys = {};

    for (final match in matches) {
      final String? value = match.group(1);

      if (value == null) {
        continue;
      }

      final String key = value.trim().toLowerCase();

      if (key.isNotEmpty) {
        keys.add(key);
      }
    }

    return keys.toList();
  }
}
