import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';

class ExpenseLimitsScreen extends StatefulWidget {
  const ExpenseLimitsScreen({super.key});

  @override
  State<ExpenseLimitsScreen> createState() => _ExpenseLimitsScreenState();
}

class _ExpenseLimitsScreenState extends State<ExpenseLimitsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> openLimitSheet({DocumentSnapshot? document}) async {
    final amountController = TextEditingController(
      text: document != null ? document['limit'].toString() : '',
    );

    String? selectedCategory;

    String? selectedCategoryId;

    String? selectedPerson;

    String? selectedPersonId;

    if (document != null) {
      selectedCategory = document['category'];

      selectedCategoryId = document['categoryId'];

      selectedPerson = document['person'];

      selectedPersonId = document['personId'];
    }

    final expenseCategories = await firestore
        .collection('expense_categories')
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    final persons = await firestore
        .collection('persons')
        .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
        .get();

    if (!mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,

                right: 20,

                top: 24,

                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    document == null
                        ? 'Add Expense Limit'
                        : 'Edit Expense Limit',

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // CATEGORY
                  // =====================
                  DropdownButtonFormField<String>(
                    value: selectedCategory,

                    decoration: InputDecoration(
                      labelText: 'Expense Category',

                      filled: true,

                      fillColor: const Color(0xFFF5F7FB),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: expenseCategories.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['title'],

                        child: Text(doc['title']),
                      );
                    }).toList(),

                    onChanged: (value) {
                      final doc = expenseCategories.docs.firstWhere((element) {
                        return element['title'] == value;
                      });

                      setSheetState(() {
                        selectedCategory = value;

                        selectedCategoryId = doc.id;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // =====================
                  // LIMIT
                  // =====================
                  TextField(
                    controller: amountController,

                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: 'Limit Amount',

                      filled: true,

                      fillColor: const Color(0xFFF5F7FB),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================
                  // PERSON
                  // =====================
                  DropdownButtonFormField<String>(
                    value: selectedPerson,

                    decoration: InputDecoration(
                      labelText: 'Person',

                      filled: true,

                      fillColor: const Color(0xFFF5F7FB),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: persons.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['title'],

                        child: Text(doc['title']),
                      );
                    }).toList(),

                    onChanged: (value) {
                      final doc = persons.docs.firstWhere((element) {
                        return element['title'] == value;
                      });

                      setSheetState(() {
                        selectedPerson = value;

                        selectedPersonId = doc.id;
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  // =====================
                  // SAVE
                  // =====================
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () async {
                        if (selectedCategory == null ||
                            selectedPerson == null ||
                            amountController.text.trim().isEmpty) {
                          return;
                        }

                        final limit = double.parse(
                          amountController.text.trim(),
                        );

                        final docId =
                            '${selectedCategoryId}_${selectedPersonId}';

                        await firestore
                            .collection('expense_limits')
                            .doc(docId)
                            .set({
                              'workspaceId':
                                  WorkspaceContext.currentWorkspaceId,

                              'category': selectedCategory,
                              'categoryId': selectedCategoryId,

                              'person': selectedPerson,
                              'personId': selectedPersonId,

                              'limit': limit,
                            });

                        if (!mounted) {
                          return;
                        }

                        Navigator.pop(context);
                      },

                      child: const Text(
                        'Save',

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Expense Limits',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF16A34A),
        elevation: 8,
        onPressed: () {
          openLimitSheet();
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Limit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('expense_limits')
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

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Expense Limits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap Add Limit to create one',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 22),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('💸', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expense Limits',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${docs.length} Active Limits',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ...docs.map((document) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text('💸', style: TextStyle(fontSize: 24)),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document['category'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                document['person'],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${document['limit'].toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 10),

                          PopupMenuButton<String>(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),

                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                size: 18,
                              ),
                            ),

                            onSelected: (value) async {
                              if (value == 'edit') {
                                openLimitSheet(document: document);
                              }

                              if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      title: const Text('Delete Limit?'),
                                      content: const Text(
                                        'Are you sure you want to delete this expense limit?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext, false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(dialogContext, true);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await firestore
                                      .collection('expense_limits')
                                      .doc(document.id)
                                      .delete();
                                }
                              }
                            },

                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined),
                                    SizedBox(width: 10),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
