import 'package:cloud_firestore/cloud_firestore.dart';

class SetupItemModel {
  final String id;

  final String title;

  final List<Map<String, dynamic>> details;

  final String workspaceId;

  const SetupItemModel({
    required this.id,
    required this.title,
    required this.details,
    required this.workspaceId,
  });

  factory SetupItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SetupItemModel(
      id: doc.id,

      title: data['title'] ?? '',

      details: List<Map<String, dynamic>>.from(data['details'] ?? []),

      workspaceId: data['workspaceId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'details': details, 'workspaceId': workspaceId};
  }
}
