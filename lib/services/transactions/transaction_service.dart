import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_collections.dart';
import '../../models/transaction_model.dart';

class TransactionService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // COLLECTION REFERENCE
  CollectionReference get
      transactionCollection {

    return _firestore.collection(
      FirestoreCollections.transactions,
    );
  }

  // CREATE TRANSACTION
  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {

    await transactionCollection.add(
      transaction.toMap(),
    );
  }

  // UPDATE TRANSACTION
  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {

    await transactionCollection
        .doc(transaction.id)
        .update(
          transaction.toMap(),
        );
  }

  // DELETE TRANSACTION
  Future<void> deleteTransaction(
    String transactionId,
  ) async {

    await transactionCollection
        .doc(transactionId)
        .delete();
  }

  // GET ALL TRANSACTIONS
  Stream<List<TransactionModel>>
      getTransactions() {

    return transactionCollection

        .orderBy(
          'date',
          descending: true,
        )

        .snapshots()

        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return TransactionModel
            .fromFirestore(doc);

      }).toList();
    });
  }

//   Stream<List<TransactionModel>>
//     getFilteredTransactions(
//   FilterModel filter,
// ) {

// Query<Map<String, dynamic>> query =
//     _firestore
//         .collection(
//           FirestoreCollections
//               .transactions,
//         );

//   // TYPE
//   if (filter.type != null) {

//     query = query.where(
//       'type',
//       isEqualTo: filter.type,
//     );
//   }

//   // CATEGORY
//   if (filter.categoryId != null) {

//     query = query.where(
//       'categoryId',
//       isEqualTo:
//           filter.categoryId,
//     );
//   }

//   // PAYMENT METHOD
//   if (filter.paymentMethodId != null) {

//     query = query.where(
//       'paymentMethodId',
//       isEqualTo:
//           filter.paymentMethodId,
//     );
//   }

//   // PERSON
//   if (filter.personId != null) {

//     query = query.where(
//       'personId',
//       isEqualTo:
//           filter.personId,
//     );
//   }

//   // TAG
//   if (filter.tagId != null) {

//     query = query.where(
//       'tagId',
//       isEqualTo:
//           filter.tagId,
//     );
//   }

//   // START DATE
//   if (filter.startDate != null) {

//     query = query.where(

//       'date',

// isGreaterThanOrEqualTo:
//     Timestamp.fromDate(
//       filter.startDate!,
//     ),
//     );
//   }

// // END DATE
// if (filter.endDate != null) {

//   final endDate = DateTime(

//     filter.endDate!.year,

//     filter.endDate!.month,

//     filter.endDate!.day,

//     23,
//     59,
//     59,
//   );

//   query = query.where(

//     'date',

//     isLessThanOrEqualTo:
//         Timestamp.fromDate(
//           endDate,
//         ),
//   );
// }

//   query = query.orderBy(
//     'date',
//     descending: true,
//   );

//   return query.snapshots().map(
//     (snapshot) {

//       List<TransactionModel>
//           transactions =

//           snapshot.docs.map((doc) {

//         return TransactionModel
//             .fromFirestore(doc);

//       }).toList();

//       // LOCAL SEARCH
//       if (filter.searchText != null &&
//           filter.searchText!
//               .trim()
//               .isNotEmpty) {

//         final search =
//             filter.searchText!
//                 .toLowerCase();

//         transactions =
//             transactions.where((t) {

//           return t.notes
//                   .toLowerCase()
//                   .contains(search) ||

//               t.detail
//                   .toLowerCase()
//                   .contains(search) ||

//               t.category
//                   .toLowerCase()
//                   .contains(search);

//         }).toList();
//       }

//       return transactions;
//     },
//   );
// }

}