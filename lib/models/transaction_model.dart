import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;

  final String type;

  final String categoryId;
  final String category;

  final String detail;

  final double amount;

  final String paymentMethodId;
  final String paymentMethod;

  final String personId;
  final String person;

  final String tagId;
  final String tag;

  final String notes;

  final DateTime date;

  final int month;

  final int year;

  final String workspaceId;

  const TransactionModel({
    required this.id,

    required this.type,

    required this.categoryId,
    required this.category,

    required this.detail,

    required this.amount,

    required this.paymentMethodId,
    required this.paymentMethod,

    required this.personId,
    required this.person,

    required this.tagId,
    required this.tag,

    required this.notes,

    required this.date,

    required this.month,

    required this.year,

    required this.workspaceId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,

      type: data['type'] ?? '',

      categoryId: data['categoryId'] ?? '',

      category: data['category'] ?? '',

      detail: data['detail'] ?? '',

      amount: (data['amount'] ?? 0).toDouble(),

      paymentMethodId: data['paymentMethodId'] ?? '',

      paymentMethod: data['paymentMethod'] ?? '',

      personId: data['personId'] ?? '',

      person: data['person'] ?? '',

      tagId: data['tagId'] ?? '',

      tag: data['tag'] ?? '',

      notes: data['notes'] ?? '',

      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),

      month: data['month'] ?? 0,

      year: data['year'] ?? 0,

      workspaceId: data['workspaceId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,

      'categoryId': categoryId,

      'category': category,

      'detail': detail,

      'amount': amount,

      'paymentMethodId': paymentMethodId,

      'paymentMethod': paymentMethod,

      'personId': personId,

      'person': person,

      'tagId': tagId,

      'tag': tag,

      'notes': notes,

      'date': Timestamp.fromDate(date),

      'month': month,

      'year': year,

      'workspaceId': workspaceId,
    };
  }
}
