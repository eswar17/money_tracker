import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/workspace/workspace_context.dart';

class AccountBalanceService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final workspaceId = WorkspaceContext.currentWorkspaceId!;

    final paymentMethodsSnapshot = await firestore
        .collection('payment_methods')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    final transactionsSnapshot = await firestore
        .collection('transactions')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    final transactions = transactionsSnapshot.docs;

    List<Map<String, dynamic>> accounts = [];

    for (final paymentMethodDoc in paymentMethodsSnapshot.docs) {
      final data = paymentMethodDoc.data();

      final List<dynamic> details = data['details'] ?? [];

      final cardType = _getDetailValue(details, 'card_type');

      if (cardType != 'Debit Card') {
        continue;
      }

      double balance = 0;

      for (final txDoc in transactions) {
        final tx = txDoc.data();

        final type = tx['type'] ?? '';

        final paymentMethodId = tx['paymentMethodId'] ?? '';

        final transferToAccount = tx['tag'] ?? '';

        final amount = (tx['amount'] ?? 0).toDouble();

        // Income

        if (type == 'Income' && paymentMethodId == paymentMethodDoc.id) {
          balance += amount;
        }

        // Expense

        if (type == 'Expense' && paymentMethodId == paymentMethodDoc.id) {
          balance -= amount;
        }

        // Transfer Out

        if (type == 'Transfer' && paymentMethodId == paymentMethodDoc.id) {
          balance -= amount;
        }

        // Transfer In

        if (type == 'Transfer' && transferToAccount == data['title']) {
          balance += amount;
        }
      }

      accounts.add({
        'id': paymentMethodDoc.id,

        'title': data['title'],

        'balance': balance,
      });
    }

    accounts.sort((a, b) {
      return (b['balance'] as double).compareTo(a['balance'] as double);
    });

    return accounts;
  }

  String? _getDetailValue(List<dynamic> details, String id) {
    try {
      return details.firstWhere((e) => e['id'] == id)['name'].toString();
    } catch (_) {
      return null;
    }
  }
}
