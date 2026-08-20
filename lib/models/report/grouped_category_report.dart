import 'package:money_tracker/models/report/grouped_report_row.dart';

class GroupedCategoryReport {
  final String category;

  final List<GroupedReportRow> rows;

  const GroupedCategoryReport({required this.category, required this.rows});

  double get expense => rows.fold(0, (sum, row) => sum + row.expense);

  double get settlement => rows.fold(0, (sum, row) => sum + row.settlement);

  double get netExpense => expense - settlement;
}
