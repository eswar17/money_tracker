import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/loan_config_model.dart';
import '../constants/firestore_collections.dart';

class LoanConfigService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<LoanConfigModel>> getConfigs(String workspaceId) {
    return firestore
        .collection(FirestoreCollections.loanConfigs)
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return LoanConfigModel.fromMap(doc.data(), doc.id);
          }).toList(),
        );
  }

  Future<void> addConfig(LoanConfigModel config) async {
    await firestore
        .collection(FirestoreCollections.loanConfigs)
        .add(config.toMap());
  }

  Future<void> updateConfig(LoanConfigModel config) async {
    await firestore
        .collection(FirestoreCollections.loanConfigs)
        .doc(config.id)
        .update(config.toMap());
  }

  Future<void> deleteConfig(String id) async {
    await firestore
        .collection(FirestoreCollections.loanConfigs)
        .doc(id)
        .delete();
  }

  Future<LoanConfigModel?> getByDetailName({
    required String workspaceId,
    required String detailName,
  }) async {
    final snapshot = await firestore
        .collection(FirestoreCollections.loanConfigs)
        .where('workspaceId', isEqualTo: workspaceId)
        .where('detailName', isEqualTo: detailName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return LoanConfigModel.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  Future<void> saveConfig(LoanConfigModel config) async {
    await firestore
        .collection('loan_configs')
        .doc(config.id)
        .set(config.toMap());
  }

  Future<void> upsertConfig(LoanConfigModel config) async {
    final existing = await getByDetailName(
      workspaceId: config.workspaceId,
      detailName: config.detailName,
    );

    if (existing == null) {
      await addConfig(config);
      return;
    }

    final updated = LoanConfigModel(
      id: existing.id,
      workspaceId: config.workspaceId,
      loanType: config.loanType,
      loanName: config.loanName,
      detailName: config.detailName,
      totalAmount: config.totalAmount,
      emiAmount: config.emiAmount,
      dueDay: config.dueDay,
      reminderEnabled: config.reminderEnabled,
      notes: config.notes,
    );

    await updateConfig(updated);
  }
}
