import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_collections.dart';
import '../../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // COLLECTION REFERENCE
  CollectionReference get transactionCollection {
    return _firestore.collection(FirestoreCollections.transactions);
  }

  // CREATE TRANSACTION
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionCollection.add(transaction.toMap());
  }

  // UPDATE TRANSACTION
  Future<void> updateTransaction(TransactionModel transaction) async {
    await transactionCollection.doc(transaction.id).update(transaction.toMap());
  }

  // DELETE TRANSACTION
  Future<void> deleteTransaction(String transactionId) async {
    await transactionCollection.doc(transactionId).delete();
  }

  // GET ALL TRANSACTIONS
  Stream<List<TransactionModel>> getTransactions(String workspaceId) {
    print('QUERYING WORKSPACE: $workspaceId');

    return transactionCollection
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs.map((doc) {
            return TransactionModel.fromFirestore(doc);
          }).toList();

          transactions.sort((a, b) => b.date.compareTo(a.date));

          return transactions;
        });
  }
}
