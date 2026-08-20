class LoanConfigModel {
  final String id;

  final String workspaceId;

  final String loanType;

  final String loanName;

  final String detailName;

  final double totalAmount;

  final double emiAmount;

  final int? dueDay;

  final bool reminderEnabled;

  final String notes;

  LoanConfigModel({
    required this.id,
    required this.workspaceId,
    required this.loanType,
    required this.loanName,
    required this.detailName,
    required this.totalAmount,
    required this.emiAmount,
    required this.dueDay,
    required this.reminderEnabled,
    required this.notes,
  });

  factory LoanConfigModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanConfigModel(
      id: id,

      workspaceId: map['workspaceId'] ?? '',

      loanType: map['loanType'] ?? '',

      loanName: map['loanName'] ?? '',

      detailName: map['detailName'] ?? '',

      totalAmount: (map['totalAmount'] ?? 0).toDouble(),

      emiAmount: (map['emiAmount'] ?? 0).toDouble(),

      dueDay: map['dueDay'],

      reminderEnabled: map['reminderEnabled'] ?? false,

      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workspaceId': workspaceId,

      'loanType': loanType,

      'loanName': loanName,

      'detailName': detailName,

      'totalAmount': totalAmount,

      'emiAmount': emiAmount,

      'dueDay': dueDay,

      'reminderEnabled': reminderEnabled,

      'notes': notes,
    };
  }

  Object? operator [](String other) {
    return null;
  }
}
