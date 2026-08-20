import 'package:money_tracker/models/transaction_model.dart';

class GroupedReportRow {
  final String detail;

  final String tag;

  final List<TransactionModel> transactions;

  final double settlement;

  const GroupedReportRow({
    required this.detail,
    required this.tag,
    required this.transactions,
    required this.settlement,
  });

  double get expense => transactions.fold(0, (sum, tx) => sum + tx.amount);

  double get netExpense => expense - settlement;
}
