class PaymentMethodModel {

  final String id;

  final String title;

  final String type;

  final String bankName;

  final String last4Digits;

  final double creditLimit;

  final int billingDate;

  final int dueDate;

  final String notes;

  const PaymentMethodModel({

    required this.id,

    required this.title,

    required this.type,

    required this.bankName,

    required this.last4Digits,

    required this.creditLimit,

    required this.billingDate,

    required this.dueDate,

    required this.notes,
  });

  factory PaymentMethodModel.fromMap(

    String id,

    Map<String, dynamic> data,
  ) {

    return PaymentMethodModel(

      id: id,

      title:
          data['title'] ?? '',

      type:
          data['type'] ?? '',

      bankName:
          data['bankName'] ?? '',

      last4Digits:
          data['last4Digits'] ?? '',

      creditLimit:
          (data['creditLimit'] ?? 0)
              .toDouble(),

      billingDate:
          data['billingDate'] ?? 0,

      dueDate:
          data['dueDate'] ?? 0,

      notes:
          data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'title': title,

      'type': type,

      'bankName': bankName,

      'last4Digits': last4Digits,

      'creditLimit': creditLimit,

      'billingDate': billingDate,

      'dueDate': dueDate,

      'notes': notes,
    };
  }
}