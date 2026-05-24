import 'package:cloud_firestore/cloud_firestore.dart';

class SetupItemModel {

  final String id;

  final String title;

  final List<String> details;

  const SetupItemModel({

    required this.id,

    required this.title,

    required this.details,
  });

  factory SetupItemModel.fromFirestore(
    DocumentSnapshot doc,
  ) {

    final data =
        doc.data()
            as Map<String, dynamic>;

    return SetupItemModel(

      id: doc.id,

      title:
          data['title'] ?? '',

      details:
          List<String>.from(
            data['details'] ?? [],
          ),
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'title': title,

      'details': details,
    };
  }
}