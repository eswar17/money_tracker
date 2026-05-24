import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/firestore_collections.dart';

import '../../models/filter_model.dart';
import '../../models/transaction_model.dart';

import '../../services/transactions/transaction_service.dart';
import '../../core/helpers/category_icon_helper.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService transactionService = TransactionService();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController searchController = TextEditingController();

  final ValueNotifier<String> searchNotifier = ValueNotifier('');

  FilterModel currentFilter = const FilterModel();

  String selectedType = 'All';

  String selectedCategory = 'All';

  String selectedDetail = 'All';

  String selectedPerson = 'All';

  String selectedPayment = 'All';

  String selectedTag = 'All';

  List<String> details = [];

  String? get categoryCollection {
    switch (selectedType) {
      case 'Income':
        return FirestoreCollections.incomeCategories;

      case 'Transfer':
        return FirestoreCollections.transferCategories;

      case 'Expense':
        return FirestoreCollections.expenseCategories;

      default:
        return null;
    }
  }

  Future<void> loadDetails(String categoryId) async {
    if (categoryCollection == null) {
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection(categoryCollection!)
        .doc(categoryId)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      details = ['All', ...List<String>.from(data['details'] ?? [])];
    });
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: currentFilter.startDate ?? DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      currentFilter = currentFilter.copyWith(startDate: picked);
    });
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: currentFilter.endDate ?? DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      currentFilter = currentFilter.copyWith(endDate: picked);
    });
  }

  void clearFilters() {
    searchController.clear();

    searchNotifier.value = '';

    setState(() {
      currentFilter = const FilterModel();

      selectedType = 'All';

      selectedCategory = 'All';

      selectedDetail = 'All';

      selectedPerson = 'All';

      selectedPayment = 'All';

      selectedTag = 'All';

      details = [];
    });
  }

  List<TransactionModel> applyLocalFilters(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((t) {
      // TYPE
      if (selectedType != 'All' && t.type != selectedType) {
        return false;
      }

      // CATEGORY
      if (selectedCategory != 'All' && t.categoryId != selectedCategory) {
        return false;
      }

      // DETAIL
      if (selectedDetail != 'All' && t.detail != selectedDetail) {
        return false;
      }

      // PERSON
      if (selectedPerson != 'All' && t.personId != selectedPerson) {
        return false;
      }

      // PAYMENT
      if (selectedPayment != 'All' && t.paymentMethodId != selectedPayment) {
        return false;
      }

      // TAG
      if (selectedTag != 'All' && t.tagId != selectedTag) {
        return false;
      }

      // START DATE
      if (currentFilter.startDate != null &&
          t.date.isBefore(currentFilter.startDate!)) {
        return false;
      }

      // END DATE
      // END DATE
      if (currentFilter.endDate != null) {
        final endDate = DateTime(
          currentFilter.endDate!.year,
          currentFilter.endDate!.month,
          currentFilter.endDate!.day,
          23,
          59,
          59,
        );

        if (t.date.isAfter(endDate)) {
          return false;
        }
      }

      // SEARCH
      final search = currentFilter.searchText?.trim().toLowerCase() ?? '';

      if (search.isNotEmpty) {
        final combined =
            '${t.category} '
                    '${t.detail} '
                    '${t.paymentMethod} '
                    '${t.person} '
                    '${t.tag} '
                    '${t.notes}'
                .toLowerCase();

        if (!combined.contains(search)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },

          icon: const Icon(Icons.menu_rounded, color: Colors.black),
        ),

        centerTitle: true,

        title: const Text(
          'All Transactions',

          style: TextStyle(
            color: Colors.black,

            fontWeight: FontWeight.w700,

            fontSize: 22,
          ),
        ),
      ),

      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.getTransactions(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          return ValueListenableBuilder(
            valueListenable: searchNotifier,

            builder: (context, _, __) {
              final transactions = applyLocalFilters(snapshot.data!);

              double income = 0;
              double expense = 0;
              double transfer = 0;

              for (final t in transactions) {
                if (t.type == 'Income') {
                  income += t.amount;
                } else if (t.type == 'Expense') {
                  expense += t.amount;
                } else {
                  transfer += t.amount;
                }
              }

              return Column(
                children: [
                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 8),

                    child: Container(
                      height: 42,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: TextField(
                        controller: searchController,

                        onChanged: (value) {
                          currentFilter = currentFilter.copyWith(
                            searchText: value,
                          );

                          searchNotifier.value = value;
                        },

                        style: const TextStyle(fontSize: 13),

                        decoration: const InputDecoration(
                          hintText: 'Search transactions',

                          prefixIcon: Icon(Icons.search, size: 20),

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.only(top: 10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // FILTERS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: typeDropdown()),

                            const SizedBox(width: 6),

                            Expanded(child: categoryDropdown()),

                            const SizedBox(width: 6),

                            Expanded(child: detailDropdown()),

                            const SizedBox(width: 6),

                            Expanded(child: personDropdown()),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(child: paymentDropdown()),

                            const SizedBox(width: 6),

                            Expanded(
                              child: dateBox(
                                label: currentFilter.startDate != null
                                    ? '${currentFilter.startDate!.day}/${currentFilter.startDate!.month}'
                                    : 'From',

                                onTap: pickStartDate,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: dateBox(
                                label: currentFilter.endDate != null
                                    ? '${currentFilter.endDate!.day}/${currentFilter.endDate!.month}'
                                    : 'To',

                                onTap: pickEndDate,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(child: tagDropdown()),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,

                          child: GestureDetector(
                            onTap: clearFilters,

                            child: const Text(
                              'Clear Filters',

                              style: TextStyle(
                                color: Colors.green,

                                fontWeight: FontWeight.w600,

                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SUMMARY
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),

                    child: Row(
                      children: [
                        Expanded(
                          child: summaryCard(
                            title: 'Income',

                            amount: income,

                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: summaryCard(
                            title: 'Expense',

                            amount: expense,

                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: summaryCard(
                            title: 'Transfer',

                            amount: transfer,

                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(child: Text('No Transactions Found'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 14, right: 10),

                            itemCount: transactions.length,

                            itemBuilder: (context, index) {
                              final transaction = transactions[index];

                              final bool showDateHeader =
                                  index == 0 ||
                                  transactions[index].date.day !=
                                      transactions[index - 1].date.day ||
                                  transactions[index].date.month !=
                                      transactions[index - 1].date.month ||
                                  transactions[index].date.year !=
                                      transactions[index - 1].date.year;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  if (showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 6,
                                      ),

                                      child: Text(
                                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',

                                        style: const TextStyle(
                                          fontSize: 16,

                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                  transactionCard(transaction),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget compactBox({required Widget child}) {
    return Container(
      height: 38,

      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),
      ),

      child: child,
    );
  }

  Widget typeDropdown() {
    return compactBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,

          isExpanded: true,

          style: const TextStyle(color: Colors.black, fontSize: 11),

          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),

            DropdownMenuItem(value: 'Expense', child: Text('Expense')),

            DropdownMenuItem(value: 'Income', child: Text('Income')),

            DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
          ],

          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedType = value;

              selectedCategory = 'All';

              selectedDetail = 'All';

              details = [];
            });
          },
        ),
      ),
    );
  }

  Widget categoryDropdown() {
    if (categoryCollection == null) {
      return compactBox(
        child: const Center(
          child: Text(
            'Category',

            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(categoryCollection!)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return compactBox(child: const SizedBox());
        }

        final docs = snapshot.data!.docs;

        return compactBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,

              isExpanded: true,

              style: const TextStyle(fontSize: 11, color: Colors.black),

              items: [
                const DropdownMenuItem(value: 'All', child: Text('All')),

                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
                    value: doc.id,

                    child: Text(
                      data['title'],

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
              ],

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                if (value == 'All') {
                  setState(() {
                    selectedCategory = 'All';

                    selectedDetail = 'All';

                    details = [];
                  });

                  return;
                }

                setState(() {
                  selectedCategory = value;
                });

                loadDetails(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget detailDropdown() {
    return compactBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDetail,

          isExpanded: true,

          style: const TextStyle(color: Colors.black, fontSize: 11),

          items: details.isEmpty
              ? const [DropdownMenuItem(value: 'All', child: Text('Detail'))]
              : details.map((detail) {
                  return DropdownMenuItem<String>(
                    value: detail,

                    child: Text(detail, style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),

          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedDetail = value;
            });
          },
        ),
      ),
    );
  }

  Widget personDropdown() {
    return firestoreDropdown(
      collection: FirestoreCollections.persons,

      value: selectedPerson,

      hint: 'Person',

      onChanged: (id) {
        setState(() {
          selectedPerson = id;
        });
      },
    );
  }

  Widget paymentDropdown() {
    return firestoreDropdown(
      collection: FirestoreCollections.paymentMethods,

      value: selectedPayment,

      hint: 'Payment',

      onChanged: (id) {
        setState(() {
          selectedPayment = id;
        });
      },
    );
  }

  Widget tagDropdown() {
    return firestoreDropdown(
      collection: FirestoreCollections.tags,

      value: selectedTag,

      hint: 'Tag',

      onChanged: (id) {
        setState(() {
          selectedTag = id;
        });
      },
    );
  }

  Widget firestoreDropdown({
    required String collection,

    required String value,

    required String hint,

    required Function(String) onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return compactBox(child: const SizedBox());
        }

        final docs = snapshot.data!.docs;

        return compactBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,

              isExpanded: true,

              style: const TextStyle(fontSize: 11, color: Colors.black),

              items: [
                DropdownMenuItem(
                  value: 'All',

                  child: Text(hint, style: const TextStyle(fontSize: 11)),
                ),

                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
                    value: doc.id,

                    child: Text(
                      data['title'],

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
              ],

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                onChanged(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget dateBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: compactBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Expanded(
              child: Text(
                label,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(fontSize: 11),
              ),
            ),

            const Icon(Icons.calendar_today_rounded, size: 12),
          ],
        ),
      ),
    );
  }

  Widget summaryCard({
    required String title,

    required double amount,

    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(
            title,

            style: TextStyle(
              color: color,

              fontWeight: FontWeight.w700,

              fontSize: 10,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '₹${amount.toStringAsFixed(0)}',

            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget transactionCard(TransactionModel transaction) {
    final bool isExpense = transaction.type == 'Expense';

    final bool isIncome = transaction.type == 'Income';

    Color amountColor = isExpense
        ? Colors.red
        : isIncome
        ? Colors.green
        : Colors.blue;

    Color iconBg = isExpense
        ? Colors.red.withOpacity(0.1)
        : isIncome
        ? Colors.green.withOpacity(0.1)
        : Colors.blue.withOpacity(0.1);

    Color iconColor = isExpense
        ? Colors.red
        : isIncome
        ? Colors.green
        : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),

      child: Row(
        children: [
          Container(
            height: 48,

            width: 48,

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Center(
              child: Text(
                CategoryIconHelper.getEmoji(transaction.detail),

                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.detail,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 13,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      '${isExpense ? '-' : '+'}₹${transaction.amount.toStringAsFixed(0)}',

                      style: TextStyle(
                        color: amountColor,

                        fontWeight: FontWeight.bold,

                        fontSize: 13,
                      ),
                    ),

                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),

                      icon: Icon(
                        Icons.more_vert,

                        size: 14,

                        color: Colors.grey.shade500,
                      ),

                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(
                                transactionId: transaction.id,

                                transactionData: transaction.toMap(),
                              ),
                            ),
                          );

                          if (result == true) {
                            setState(() {});
                          }
                        } else if (value == 'delete') {
                          await transactionService.deleteTransaction(
                            transaction.id,
                          );
                        }
                      },

                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',

                            child: Text('Edit'),
                          ),

                          const PopupMenuItem(
                            value: 'delete',

                            child: Text('Delete'),
                          ),
                        ];
                      },
                    ),
                  ],
                ),

                Text(
                  '${transaction.category} • ${transaction.paymentMethod} • ${transaction.person} • ${transaction.tag}${transaction.notes.isNotEmpty ? ' • ${transaction.notes}' : ''}',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
