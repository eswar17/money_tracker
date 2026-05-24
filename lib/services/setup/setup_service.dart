import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/setup_item_model.dart';

class SetupService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<SetupItemModel>>
      getItems(
    String collection,
  ) {

    return _firestore

        .collection(collection)

        .snapshots()

        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return SetupItemModel
            .fromFirestore(doc);

      }).toList();
    });
  }

  Future<void> addItem({

    required String collection,

    required SetupItemModel item,
  }) async {

    await _firestore
        .collection(collection)
        .add(
          item.toMap(),
        );
  }

  Future<void> updateItem({

    required String collection,

    required SetupItemModel item,
  }) async {

    await _firestore
        .collection(collection)
        .doc(item.id)
        .update(
          item.toMap(),
        );
  }

  Future<void> deleteItem({

    required String collection,

    required String id,
  }) async {

    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }
}