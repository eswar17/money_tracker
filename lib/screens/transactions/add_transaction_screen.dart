import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';
import 'package:money_tracker/theme/app_colors.dart';

import '../../constants/firestore_collections.dart';
import '../../models/transaction_model.dart';
import '../../services/transactions/transaction_service.dart';
import '../../services/auth/workspace_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;

  final String? transactionId;

  const AddTransactionScreen({
    super.key,

    this.transactionData,
    this.transactionId,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionService transactionService = TransactionService();

  String selectedType = 'Expense';

  String? selectedCategoryId;
  String? selectedCategoryName;

  String? selectedDetail;

  String? selectedPaymentMethodId;
  String? selectedPaymentMethodName;

  String? selectedPersonId;
  String? selectedPersonName;

  String? selectedTagId;
  String? selectedTagName;

  String? selectedDetailId;

  List<Map<String, dynamic>> detailList = [];

  DateTime selectedDate = DateTime.now();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(FirebaseAuth.instance.currentUser?.uid);
    loadExistingData();
  }

  void loadExistingData() {
    final data = widget.transactionData;

    if (data == null) {
      return;
    }

    selectedType = data['type'];

    selectedCategoryId = data['categoryId'];

    selectedCategoryName = data['category'];

    selectedDetailId = data['detailId'];

    selectedDetail = data['detail'];

    selectedPaymentMethodId = data['paymentMethodId'];

    selectedPaymentMethodName = data['paymentMethod'];

    selectedPersonId = data['personId'];

    selectedPersonName = data['person'];

    selectedTagId = data['tagId'];

    selectedTagName = data['tag'];

    amountController.text = data['amount'].toString();

    notesController.text = data['notes'] ?? '';

    selectedDate = (data['date'] as Timestamp).toDate();

    loadDetails(selectedCategoryId!);
  }

  String get categoryCollection {
    switch (selectedType) {
      case 'Income':
        return FirestoreCollections.incomeCategories;

      case 'Transfer':
        return FirestoreCollections.transferCategories;

      default:
        return FirestoreCollections.expenseCategories;
    }
  }

  Future<void> loadDetails(String categoryId) async {
    final doc = await FirebaseFirestore.instance
        .collection(categoryCollection)
        .doc(categoryId)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      detailList = List<Map<String, dynamic>>.from(data['details'] ?? []);
    });
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,

      initialDate: selectedDate,

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  Future<void> saveTransaction() async {
    if (selectedCategoryId == null ||
        selectedDetailId == null ||
        selectedPaymentMethodId == null ||
        selectedPersonId == null ||
        amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));

      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    final workspaceId = await WorkspaceService.getCurrentWorkspaceId();

    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid Amount')));

      return;
    }

    final transaction = TransactionModel(
      id: widget.transactionId ?? '',

      workspaceId: workspaceId,

      type: selectedType,

      categoryId: selectedCategoryId!,

      category: selectedCategoryName!,

      detailId: selectedDetailId!,

      detail: selectedDetail!,

      amount: amount,

      paymentMethodId: selectedPaymentMethodId!,

      paymentMethod: selectedPaymentMethodName!,

      personId: selectedPersonId!,

      person: selectedPersonName!,

      tagId: selectedTagId ?? '',

      tag: selectedTagName ?? '',

      notes: notesController.text.trim(),

      date: selectedDate,

      month: selectedDate.month,

      year: selectedDate.year,
    );

    if (widget.transactionId != null) {
      await transactionService.updateTransaction(transaction);
    } else {
      await transactionService.addTransaction(transaction);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor;

    switch (selectedType) {
      case 'Income':
        buttonColor = AppColors.income;
        break;

      case 'Transfer':
        buttonColor = AppColors.transfer;
        break;

      default:
        buttonColor = AppColors.expense;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),

        elevation: 0,

        centerTitle: true,

        title: Text(
          widget.transactionId != null ? 'Edit Transaction' : 'Add Transaction',

          style: const TextStyle(
            color: Colors.black,

            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // TYPE BAR
            Container(
              padding: const EdgeInsets.all(3),

              decoration: BoxDecoration(
                color: const Color(0xFFE8ECEF),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Row(
                children: [
                  typeButton('Expense'),

                  typeButton('Income'),

                  typeButton('Transfer'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // AMOUNT
            modernTextField(
              controller: amountController,

              hint: 'Amount*',

              icon: Icons.currency_rupee,

              iconColor: Colors.black,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 14),

            // CATEGORY
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(categoryCollection)
                  .where(
                    'workspaceId',
                    isEqualTo: WorkspaceContext.currentWorkspaceId,
                  )
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return modernDropdown<String>(
                  icon: Icons.category_rounded,

                  iconColor: Colors.green,

                  hint: 'Select Category*',

                  value: selectedCategoryId,

                  items: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: doc.id,

                      child: Text(data['title']),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    final selectedDoc = docs.firstWhere(
                      (doc) => doc.id == value,
                    );

                    final selectedData =
                        selectedDoc.data() as Map<String, dynamic>;

                    setState(() {
                      selectedCategoryId = selectedDoc.id;

                      selectedCategoryName = selectedData['title'];

                      selectedDetail = null;

                      selectedDetailId = null;
                    });

                    loadDetails(value);
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // DETAIL
            modernDropdown<String>(
              icon: Icons.receipt_long_rounded,

              iconColor: Colors.orange,

              hint: 'Select Detail*',

              value: selectedDetailId,

              items: detailList.map((detail) {
                return DropdownMenuItem<String>(
                  value: detail['id'],
                  child: Text(detail['name']),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    return;
                  }

                  final selected = detailList.firstWhere(
                    (e) => e['id'] == value,
                  );

                  setState(() {
                    selectedDetailId = selected['id'];

                    selectedDetail = selected['name'];
                  });
                });
              },
            ),

            const SizedBox(height: 14),

            // PAYMENT
            firestoreDropdown(
              collection: FirestoreCollections.paymentMethods,

              label: 'Select Payment Method*',

              icon: Icons.account_balance_wallet_rounded,

              iconColor: Colors.blue,

              value: selectedPaymentMethodId,

              onChanged: (id, name) {
                setState(() {
                  selectedPaymentMethodId = id;

                  selectedPaymentMethodName = name;
                });
              },
            ),

            const SizedBox(height: 14),

            // PERSON
            firestoreDropdown(
              collection: FirestoreCollections.persons,

              label: 'Select Person*',

              icon: Icons.people_alt_rounded,

              iconColor: Colors.deepPurple,

              value: selectedPersonId,

              onChanged: (id, name) {
                setState(() {
                  selectedPersonId = id;

                  selectedPersonName = name;
                });
              },
            ),

            const SizedBox(height: 14),

            // TAG
            firestoreDropdown(
              collection: FirestoreCollections.tags,

              label: 'Select Tag (Optional)',

              icon: Icons.sell_rounded,

              iconColor: const Color.fromARGB(255, 23, 75, 73),

              value: selectedTagId,

              onChanged: (id, name) {
                setState(() {
                  selectedTagId = id;

                  selectedTagName = name;
                });
              },
            ),

            const SizedBox(height: 14),

            // NOTES
            modernTextField(
              controller: notesController,

              hint: 'Add Notes (Optional)',

              icon: Icons.notes_rounded,

              iconColor: Colors.brown,

              maxLines: 1,
            ),

            const SizedBox(height: 12),

            // DATE
            GestureDetector(
              onTap: pickDate,

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Colors.black),

                    const SizedBox(width: 12),

                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            SizedBox(
              width: double.infinity,

              height: 48,

              child: ElevatedButton(
                onPressed: saveTransaction,

                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                child: Text(
                  widget.transactionId != null
                      ? 'Update Transaction'
                      : 'Save Transaction',

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 15,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typeButton(String type) {
    final bool isSelected = selectedType == type;

    Color activeColor;

    switch (type) {
      case 'Income':
        activeColor = AppColors.income; // Green
        break;

      case 'Transfer':
        activeColor = AppColors.transfer; // Blue
        break;

      default:
        activeColor = AppColors.expense; // Red Expense
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = type;

            selectedCategoryId = null;
            selectedCategoryName = null;

            selectedDetailId = null;
            selectedDetail = null;

            detailList = [];
          });
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,

            borderRadius: BorderRadius.circular(30),
          ),

          child: Center(
            child: Text(
              type,

              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,

                fontSize: 12,

                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget modernTextField({
    required TextEditingController controller,

    required String hint,

    required IconData icon,

    required Color iconColor,

    int maxLines = 1,

    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: TextField(
        controller: controller,

        maxLines: maxLines,

        keyboardType: keyboardType,

        decoration: InputDecoration(
          border: InputBorder.none,

          icon: Icon(icon, color: iconColor, size: 22),

          hintText: hint,

          hintStyle: TextStyle(
            color: Colors.grey.shade500,

            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget modernDropdown<T>({
    required IconData icon,

    required Color iconColor,

    required String hint,

    required T? value,

    required List<DropdownMenuItem<T>> items,

    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: DropdownButtonFormField<T>(
        value: value,

        items: items,

        onChanged: onChanged,

        decoration: InputDecoration(
          border: InputBorder.none,

          icon: Icon(icon, color: iconColor),

          hintText: hint,

          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget firestoreDropdown({
    required String collection,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required Function(String id, String name) onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        String? dropdownValue = value;

        final exists = docs.any((doc) => doc.id == value);

        if (!exists) {
          dropdownValue = null;
        }

        return modernDropdown<String>(
          icon: icon,

          iconColor: iconColor,

          hint: label,

          value: dropdownValue,

          items: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return DropdownMenuItem<String>(
              value: doc.id,

              child: Text(data['title']),
            );
          }).toList(),

          onChanged: (value) {
            if (value == null) {
              return;
            }

            final selectedDoc = docs.firstWhere((doc) => doc.id == value);

            final selectedData = selectedDoc.data() as Map<String, dynamic>;

            onChanged(selectedDoc.id, selectedData['title']);
          },
        );
      },
    );
  }
}
