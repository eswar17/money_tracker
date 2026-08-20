import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/widgets/menu_button.dart';
import '../../constants/firestore_collections.dart';
import '../../models/filter_model.dart';
import '../../models/transaction_model.dart';
import '../../services/auth/workspace_service.dart';
import '../../services/transactions/transaction_service.dart';
import '../../services/pdf/pdf_service.dart';
import 'add_transaction_screen.dart';
import './widgets/transaction_summary_card.dart';
import './widgets/transaction_filters.dart';
import '../../widgets/app_drawer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../constants/app_strings.dart';
import './widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TransactionsScreen({super.key, required this.scaffoldKey});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService transactionService = TransactionService();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> searchNotifier = ValueNotifier('');
  FilterModel currentFilter = const FilterModel();
  String selectedType = AppStrings.all;
  String selectedCategory = AppStrings.all;
  String selectedDetailId = AppStrings.all;
  String selectedPerson = AppStrings.all;
  String selectedPayment = AppStrings.all;
  String selectedTag = AppStrings.all;
  String? workspaceId;
  List<Map<String, dynamic>> details = [];
  String? get categoryCollection {
    switch (selectedType) {
      case AppStrings.income:
        return FirestoreCollections.incomeCategories;
      case AppStrings.transfer:
        return FirestoreCollections.transferCategories;
      case AppStrings.expense:
        return FirestoreCollections.expenseCategories;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadWorkspace();
  }

  Future<void> loadWorkspace() async {
    final id = await WorkspaceService.getCurrentWorkspaceId();
    print('WORKSPACE ID: $id');
    setState(() {
      workspaceId = id;
    });
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
      details = [
        {'id': AppStrings.all, 'name': AppStrings.all},
        ...List<Map<String, dynamic>>.from(data['details'] ?? []),
      ];
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
      selectedType = AppStrings.all;
      selectedCategory = AppStrings.all;
      selectedDetailId = AppStrings.all;
      selectedPerson = AppStrings.all;
      selectedPayment = AppStrings.all;
      selectedTag = AppStrings.all;
      details = [];
    });
  }

  void _showExportOptions(
    List<TransactionModel> transactions,
    List<TransactionModel> allTransactions,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Export Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffEEF5FF),
                    child: Icon(Icons.description_outlined, color: Colors.blue),
                  ),
                  title: const Text(
                    'Detailed Transactions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Every transaction with all details'),
                  onTap: () async {
                    Navigator.pop(context);
                    PdfService().exportDetailedReport(
                      transactions: transactions,
                      person: selectedPerson,
                      category: selectedCategory,
                      payment: selectedPayment,
                      tag: selectedTag,
                      startDate: currentFilter.startDate,
                      endDate: currentFilter.endDate,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffEEF7EE),
                    child: Icon(Icons.analytics_outlined, color: Colors.green),
                  ),
                  title: const Text(
                    'Grouped Report',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Expense analysis with settlements'),

                  onTap: () async {
                    Navigator.pop(context);
                    await PdfService().exportGroupedReport(
                      transactions: transactions,
                      allTransactions: allTransactions,
                      person: selectedPerson,
                      category: selectedCategory,
                      payment: selectedPayment,
                      tag: selectedTag,
                      startDate: currentFilter.startDate,
                      endDate: currentFilter.endDate,
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TransactionModel> applyLocalFilters(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((t) {
      // TYPE
      if (selectedType != AppStrings.all && t.type != selectedType) {
        return false;
      }
      // CATEGORY
      if (selectedCategory != AppStrings.all &&
          t.categoryId != selectedCategory) {
        return false;
      }
      // DETAIL
      if (selectedDetailId != AppStrings.all &&
          t.detailId != selectedDetailId) {
        return false;
      }
      // PERSON
      if (selectedPerson != AppStrings.all && t.personId != selectedPerson) {
        return false;
      }
      // PAYMENT
      if (selectedPayment != AppStrings.all &&
          t.paymentMethodId != selectedPayment) {
        return false;
      }
      // TAG
      if (selectedTag == '__NO_TAG__') {
        if (t.tagId.isNotEmpty) {
          return false;
        }
      } else if (selectedTag != AppStrings.all && t.tagId != selectedTag) {
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
      backgroundColor: AppColors.background,
      //  drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: MenuButton(
          onTap: () {
            widget.scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        title: Text(AppStrings.allTransactions, style: AppTextStyles.heading3),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
        //     onPressed: () {
        //       _showExportOptions(transactions);
        //     },
        //   ),
        // ],
      ),
      body: workspaceId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<TransactionModel>>(
              stream: transactionService.getTransactions(workspaceId!),
              builder: (context, snapshot) {
                print('========================');
                print('WORKSPACE: $workspaceId');
                print('HAS ERROR: ${snapshot.hasError}');
                print('ERROR: ${snapshot.error}');
                print('HAS DATA: ${snapshot.hasData}');
                print('DOC COUNT: ${snapshot.data?.length}');
                print('STATE: ${snapshot.connectionState}');
                print('========================');
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No Data'));
                }
                // if (!snapshot.hasData) {
                //   return const SizedBox();
                // }
                return ValueListenableBuilder(
                  valueListenable: searchNotifier,
                  builder: (context, _, _) {
                    final allTransactions = snapshot.data!;
                    final transactions = applyLocalFilters(allTransactions);
                    double income = 0;
                    double expense = 0;
                    double transfer = 0;
                    for (final t in transactions) {
                      if (t.type == AppStrings.income) {
                        income += t.amount;
                      } else if (t.type == AppStrings.expense) {
                        expense += t.amount;
                      } else {
                        transfer += t.amount;
                      }
                    }
                    return Column(
                      children: [
                        // SEARCH
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.md,
                            top: AppSpacing.xs,
                          ),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.card,
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
                              style: AppTextStyles.bodyMedium,
                              decoration: const InputDecoration(
                                hintText: AppStrings.searchTransactions,
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
                          child: TransactionFilters(
                            transactionCount: transactions.length,
                            selectedType: selectedType,
                            selectedCategory: selectedCategory,
                            selectedDetailId: selectedDetailId,
                            selectedPerson: selectedPerson,
                            selectedPayment: selectedPayment,
                            selectedTag: selectedTag,
                            categoryCollection: categoryCollection,
                            details: details,
                            startDate: currentFilter.startDate,
                            endDate: currentFilter.endDate,
                            onStartDateTap: pickStartDate,
                            onEndDateTap: pickEndDate,
                            onClearFilters: clearFilters,
                            onTypeChanged: (value) {
                              setState(() {
                                selectedType = value;
                                selectedCategory = AppStrings.all;
                                selectedDetailId = AppStrings.all;
                                details = [];
                              });
                            },
                            onCategoryChanged: (value) {
                              if (value == AppStrings.all) {
                                setState(() {
                                  selectedCategory = AppStrings.all;
                                  selectedDetailId = AppStrings.all;
                                  details = [];
                                });
                                return;
                              }
                              setState(() {
                                selectedCategory = value;
                              });
                              loadDetails(value);
                            },
                            onDetailChanged: (value) {
                              setState(() {
                                selectedDetailId = value;
                              });
                            },
                            onPersonChanged: (value) {
                              setState(() {
                                selectedPerson = value;
                              });
                            },
                            onPaymentChanged: (value) {
                              setState(() {
                                selectedPayment = value;
                              });
                            },
                            onTagChanged: (value) {
                              setState(() {
                                selectedTag = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // SUMMARY
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: TransactionSummaryCard(
                                  title: AppStrings.income,
                                  amount: income,
                                  color: AppColors.income,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TransactionSummaryCard(
                                  title: AppStrings.expense,
                                  amount: expense,
                                  color: AppColors.expense,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TransactionSummaryCard(
                                  title: AppStrings.transfer,
                                  amount: transfer,
                                  color: AppColors.transfer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _showExportOptions(
                                  transactions,
                                  allTransactions,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf_rounded),
                              label: const Text('Export Report'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Expanded(
                          child: transactions.isEmpty
                              ? const Center(
                                  child: Text(AppStrings.noTransactionsFound),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                    final bool showDateHeader =
                                        index == 0 ||
                                        transactions[index].date.day !=
                                            transactions[index - 1].date.day ||
                                        transactions[index].date.month !=
                                            transactions[index - 1]
                                                .date
                                                .month ||
                                        transactions[index].date.year !=
                                            transactions[index - 1].date.year;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Dismissible(
                                          key: ValueKey(transaction.id),

                                          background: Container(
                                            alignment: Alignment.centerLeft,

                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),

                                            color: Colors.blue,

                                            child: const Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                            ),
                                          ),

                                          secondaryBackground: Container(
                                            alignment: Alignment.centerRight,

                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),

                                            color: Colors.red,

                                            child: const Icon(
                                              Icons.delete_rounded,
                                              color: Colors.white,
                                            ),
                                          ),

                                          confirmDismiss: (direction) async {
                                            if (direction ==
                                                DismissDirection.startToEnd) {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddTransactionScreen(
                                                            transactionId:
                                                                transaction.id,
                                                            transactionData:
                                                                transaction
                                                                    .toMap(),
                                                          ),
                                                    ),
                                                  );

                                              if (result == true) {
                                                setState(() {});
                                              }

                                              return false;
                                            }

                                            return await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Delete Transaction',
                                                      ),

                                                      content: const Text(
                                                        'Are you sure?',
                                                      ),

                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),

                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) ??
                                                false;
                                          },

                                          onDismissed: (direction) async {
                                            await transactionService
                                                .deleteTransaction(
                                                  transaction.id,
                                                );
                                          },

                                          child: TransactionCard(
                                            transaction: transaction,

                                            onEdit: () {},

                                            onDelete: () {},
                                          ),
                                        ),
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
}
