import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/helpers/app_emoji_helper.dart';
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

  Future<void> openCategoryPicker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(categoryCollection)
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,

            child: Column(
              children: [
                const SizedBox(height: 16),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.docs.length,

                    itemBuilder: (context, index) {
                      final doc = snapshot.docs[index];

                      final data = doc.data();

                      return ListTile(
                        leading: Text(
                          AppEmojiHelper.getEmoji(data['title']),
                          style: const TextStyle(fontSize: 24),
                        ),

                        title: Text(
                          data['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        trailing: const Icon(Icons.chevron_right_rounded),

                        onTap: () {
                          setState(() {
                            selectedCategoryId = doc.id;

                            selectedCategoryName = data['title'];

                            selectedDetail = null;
                            selectedDetailId = null;
                          });

                          loadDetails(doc.id);

                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required Function(Map<String, dynamic>) onSelected,
  }) async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,

            child: Column(
              children: [
                const SizedBox(height: 16),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,

                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ListTile(
                        leading: Text(
                          AppEmojiHelper.getEmoji(item['title']),
                          style: const TextStyle(fontSize: 24),
                        ),

                        title: Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        trailing: const Icon(Icons.chevron_right_rounded),

                        onTap: () {
                          onSelected(item);

                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openPaymentPicker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirestoreCollections.paymentMethods)
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    final items = snapshot.docs.map((doc) {
      final data = doc.data();

      return {'id': doc.id, 'title': data['title']};
    }).toList();

    await openPicker(
      title: 'Select Payment Method',

      items: items,

      onSelected: (item) {
        setState(() {
          selectedPaymentMethodId = item['id'];

          selectedPaymentMethodName = item['title'];
        });
      },
    );
  }

  Future<void> openPersonPicker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirestoreCollections.persons)
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    final items = snapshot.docs.map((doc) {
      final data = doc.data();

      return {'id': doc.id, 'title': data['title']};
    }).toList();

    await openPicker(
      title: 'Select Person',

      items: items,

      onSelected: (item) {
        setState(() {
          selectedPersonId = item['id'];

          selectedPersonName = item['title'];
        });
      },
    );
  }

  Future<void> openTagPicker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirestoreCollections.tags)
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    final items = snapshot.docs.map((doc) {
      final data = doc.data();

      return {'id': doc.id, 'title': data['title']};
    }).toList();

    await openPicker(
      title: 'Select Tag',

      items: items,

      onSelected: (item) {
        setState(() {
          selectedTagId = item['id'];

          selectedTagName = item['title'];
        });
      },
    );
  }

  Future<void> openDetailPicker() async {
    if (detailList.isEmpty) return;

    final items = detailList.map((detail) {
      return {'id': detail['id'], 'title': detail['name']};
    }).toList();

    await openPicker(
      title: 'Select Detail',

      items: items,

      onSelected: (item) {
        setState(() {
          selectedDetailId = item['id'];

          selectedDetail = item['title'];
        });
      },
    );
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
            pickerTile(
              title: 'Category',
              value: selectedCategoryName ?? '',
              emoji: selectedCategoryName == null
                  ? '📂'
                  : AppEmojiHelper.getEmoji(selectedCategoryName),
              onTap: openCategoryPicker,
            ),

            const SizedBox(height: 14),

            // DETAIL
            pickerTile(
              title: 'Detail',
              value: selectedDetail ?? '',
              emoji: selectedDetail == null
                  ? '🧾'
                  : AppEmojiHelper.getEmoji(selectedDetail),
              onTap: openDetailPicker,
            ),

            const SizedBox(height: 14),

            // PAYMENT
            pickerTile(
              title: 'Payment',
              value: selectedPaymentMethodName ?? '',
              emoji: selectedPaymentMethodName == null
                  ? '💰'
                  : AppEmojiHelper.getEmoji(selectedPaymentMethodName),
              onTap: openPaymentPicker,
            ),

            const SizedBox(height: 14),

            // PERSON
            pickerTile(
              title: 'Person',
              value: selectedPersonName ?? '',
              emoji: '👨',
              // selectedPersonName == null
              //     ? '👥'
              //     : AppEmojiHelper.getEmoji(selectedPersonName),
              onTap: openPersonPicker,
            ),

            const SizedBox(height: 14),

            // TAG
            pickerTile(
              title: 'Tag',
              value: selectedTagName ?? '',
              emoji: selectedTagName == null
                  ? '🏷️'
                  : AppEmojiHelper.getEmoji(selectedTagName),
              onTap: openTagPicker,
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
            pickerTile(
              title: 'Date',

              value:
                  '${selectedDate.day.toString().padLeft(2, '0')}/'
                  '${selectedDate.month.toString().padLeft(2, '0')}/'
                  '${selectedDate.year}',

              emoji: '📅',

              onTap: pickDate,
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

  Widget pickerTile({
    required String title,
    required String value,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final bool hasValue = value.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: Colors.grey.shade200),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(14),
              ),

              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title.toUpperCase(),

                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    hasValue ? value : 'Select $title',

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: hasValue ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 32,
              width: 32,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.chevron_right_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget datePickerTile() {
    return GestureDetector(
      onTap: pickDate,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: Colors.grey.shade200),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color: const Color(0xFFEEF8F0),

                borderRadius: BorderRadius.circular(14),
              ),

              child: const Center(
                child: Text('📅', style: TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'DATE',

                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

              decoration: BoxDecoration(
                color: const Color(0xFFEEF8F0),

                borderRadius: BorderRadius.circular(12),
              ),

              child: const Text(
                'Change',

                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
