import 'package:flutter/material.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';
import '../../constants/firestore_collections.dart';
import '../../models/setup_item_model.dart';
import '../../services/setup/setup_service.dart';

import '../../services/dashboard/dashboard_service.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/menu_button.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DashboardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DashboardScreen({super.key, required this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService dashboardService = DashboardService();
  final SetupService setupService = SetupService();

  DateTime selectedMonth = DateTime.now();

  String selectedPerson = 'All';

  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  void loadDashboard() {
    dashboardFuture = dashboardService.getDashboardData(
      selectedMonth,
      selectedPerson,
      WorkspaceContext.currentWorkspaceId!,
    );
  }

  void changeMonth(int value) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + value);

      loadDashboard();
    });
  }

  void changePerson(String person) {
    setState(() {
      selectedPerson = person;

      loadDashboard();
    });
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      //drawer: const AppDrawer(),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: dashboardFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No Data'));
            }

            final data = snapshot.data!;
            final double percentage = ((data['percentageChange'] ?? 0)
                .toDouble());

            final bool isPositive = percentage >= 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =====================
                  // TOP BAR
                  // =====================
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          return MenuButton(
                            onTap: () {
                              widget.scaffoldKey.currentState?.openDrawer();
                            },
                          );
                        },
                      ),

                      const Spacer(),

                      Text('Dashboard', style: AppTextStyles.heading2),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // MONTH PICKER
                  // =====================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,

                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            changeMonth(-1);
                          },

                          child: const Icon(Icons.chevron_left_rounded),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,

                                initialDate: selectedMonth,

                                firstDate: DateTime(2020),

                                lastDate: DateTime(2035),

                                initialDatePickerMode: DatePickerMode.year,
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  selectedMonth = DateTime(
                                    pickedDate.year,

                                    pickedDate.month,
                                  );

                                  loadDashboard();
                                });
                              }
                            },

                            child: Center(
                              child: Text(
                                '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',

                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            changeMonth(1);
                          },

                          child: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // PERSON FILTER
                  // =====================
                  // =====================
                  // PERSON FILTER
                  // =====================
                  StreamBuilder<List<SetupItemModel>>(
                    stream: setupService.getItems(
                      FirestoreCollections.persons,
                      WorkspaceContext.currentWorkspaceId!,
                    ),

                    builder: (context, snapshot) {
                      final persons = snapshot.data ?? [];

                      // Dashboard Visible only
                      final dashboardPersons = persons.where((person) {
                        if (person.details.isEmpty) return false;

                        return person.details.first['dashboardVisible'] == true;
                      }).toList();

                      // Sort by Dashboard Order
                      dashboardPersons.sort((a, b) {
                        final orderA =
                            (a.details.first['dashboardOrder'] ?? 999) as int;

                        final orderB =
                            (b.details.first['dashboardOrder'] ?? 999) as int;

                        return orderA.compareTo(orderB);
                      });

                      final filters = [
                        'All',
                        ...dashboardPersons.map((e) => e.title),
                      ];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          children: filters.map((person) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),

                              child: SizedBox(
                                width: 90,

                                child: personChip(person),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // =====================
                  // BALANCE CARD
                  // =====================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                        colors: [
                          Color(0xFF111827),

                          Color(0xFF1F2937),

                          Color(0xFF374151),
                        ],
                      ),

                      borderRadius: BorderRadius.circular(32),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.22),

                          blurRadius: 35,

                          spreadRadius: 2,

                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // =====================
                        // TOP ROW
                        // =====================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // LEFT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    'Available Balance',

                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    '₹${((data['balance'] ?? 0).toDouble()).toStringAsFixed(0)}',

                                    style: AppTextStyles.heading1.copyWith(
                                      color: Colors.white,

                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,

                                        color: isPositive
                                            ? const Color(0xFF86EFAC)
                                            : const Color(0xFFFCA5A5),

                                        size: 18,
                                      ),

                                      const SizedBox(width: 6),

                                      Text(
                                        '${percentage.toStringAsFixed(1)}% vs prev month',

                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isPositive
                                              ? const Color(0xFFBBF7D0)
                                              : const Color(0xFFFECACA),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),

                            // =====================
                            // GRAPH
                            // =====================
                            SizedBox(
                              height: 100,

                              width: 100,

                              child: SavingsMeter(
                                income: (data['income'] ?? 0).toDouble(),

                                savings: (data['savings'] ?? 0).toDouble(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // =====================
                        // INCOME EXPENSE SAVINGS
                        // =====================
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,

                            vertical: 16,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(22),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              balanceItem(
                                title: 'Income',

                                amount: (data['income'] ?? 0).toDouble(),
                              ),

                              balanceItem(
                                title: 'Expense',

                                amount: (data['expense'] ?? 0).toDouble(),
                              ),

                              balanceItem(
                                title: 'Savings',

                                amount: (data['savings'] ?? 0).toDouble(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // =====================
                  // INCOME EXPENSE SAVINGS
                  // =====================
                  const SizedBox(height: 28),

                  // =====================
                  // LIMITS
                  // =====================
                  Text('Expense Limits', style: AppTextStyles.heading3),

                  const SizedBox(height: 16),

                  if ((data['expenseLimits'] ?? []).isEmpty)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: const Center(child: Text('No Expense Limits')),
                    )
                  else
                    ...((data['expenseLimits'] ?? []) as List).map((limitData) {
                      return limitTile(
                        category: limitData['category'],

                        spent: (limitData['spent'] ?? 0).toDouble(),

                        limit: (limitData['limit'] ?? 0).toDouble(),
                      );
                    }),

                  const SizedBox(height: 28),

                  // =====================
                  // TOP CATEGORIES
                  // =====================
                  Text(
                    'Top Spending Categories',

                    style: AppTextStyles.heading3,
                  ),

                  const SizedBox(height: 16),

                  if ((data['topCategories'] ?? []).isEmpty)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: const Center(child: Text('No Category Data')),
                    )
                  else
                    ...((data['topCategories'] ?? []) as List).map((
                      categoryData,
                    ) {
                      return categoryTile(
                        category: categoryData.key,

                        amount: categoryData.value.toDouble(),
                        totalExpense: data['expense'],
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget personChip(String person) {
    final bool isSelected = selectedPerson == person;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          changePerson(person);
        },

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,

            borderRadius: BorderRadius.circular(16),
          ),

          child: Center(
            child: Text(
              person,

              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : Colors.black87,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryCard({
    required String title,

    required double amount,

    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),
        ),

        child: Stack(
          children: [
            Positioned(
              top: -40,

              right: -30,

              child: Container(
                height: 140,

                width: 140,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.18),

                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -30,

              left: -20,

              child: Container(
                height: 100,

                width: 100,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF8B5CF6).withOpacity(0.28),

                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Text(title, style: AppTextStyles.bodySmall),

                const SizedBox(height: 10),

                Text(
                  '₹${amount.toStringAsFixed(0)}',

                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget limitTile({
    required String category,

    required double spent,

    required double limit,
  }) {
    final double progress = spent / limit;

    String emoji = '😎';

    if (progress > 0.8) {
      emoji = '😬';
    }

    if (progress >= 1) {
      emoji = '💀';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Text(category),

              const Spacer(),

              Text('₹${spent.toStringAsFixed(0)}/₹${limit.toStringAsFixed(0)}'),

              const SizedBox(width: 10),

              Text(emoji),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 8,

              backgroundColor: Colors.grey.shade200,

              valueColor: AlwaysStoppedAnimation(
                progress >= 1
                    ? Colors.red
                    : progress > 0.8
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget balanceItem({required String title, required double amount}) {
    return Column(
      children: [
        Text(
          title,

          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),

        const SizedBox(height: 6),

        Text(
          '₹${amount.toStringAsFixed(0)}',

          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;

      case 'Transport':
        return Colors.indigo;

      case 'Health':
        return Colors.red;

      case 'Household':
        return Colors.brown;

      case 'Bills':
        return Colors.blueGrey;

      case 'Lifestyle':
        return Colors.purple;

      case 'Entertainment':
        return Colors.pink;

      case 'Subscriptions':
        return Colors.deepPurple;

      case 'Savings':
        return Colors.green;

      case 'Charity':
        return Colors.teal;

      case 'Gifts':
        return Colors.amber;

      case 'Trips':
        return Colors.cyan;

      case 'Loans':
        return Colors.deepOrange;

      case 'Insurance':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  String getCategoryEmoji(String category) {
    switch (category) {
      case 'Food':
        return '🍔';

      case 'Transport':
        return '🚕';

      case 'Health':
        return '💊';

      case 'Household':
        return '🏠';

      case 'Bills':
        return '📄';

      case 'Lifestyle':
        return '🛍';

      case 'Entertainment':
        return '🎬';

      case 'Subscriptions':
        return '📺';

      case 'Savings':
        return '📈';

      case 'Charity':
        return '🙏';

      case 'Gifts':
        return '🎁';

      case 'Trips':
        return '✈️';

      case 'Loans':
        return '💀';

      case 'Insurance':
        return '🛡';

      default:
        return '📊';
    }
  }

  Widget categoryTile({
    required String category,

    required double amount,

    required double totalExpense,
  }) {
    final color = getCategoryColor(category);

    final icon = getCategoryEmoji(category);

    final double progress = totalExpense <= 0
        ? 0
        : (amount / totalExpense).clamp(0, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [color.withOpacity(0.10), Colors.white],
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: color.withOpacity(0.08)),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              // =====================
              // ICON
              // =====================
              Container(
                height: 52,

                width: 52,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 14),

              // =====================
              // CATEGORY
              // =====================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      category,

                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% of total expenses',

                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // =====================
              // AMOUNT
              // =====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    '₹${amount.toStringAsFixed(0)}',

                    style: AppTextStyles.heading3.copyWith(color: color),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',

                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =====================
          // PROGRESS BAR
          // =====================
          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 10,

              backgroundColor: color.withOpacity(0.10),

              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsMeter extends StatelessWidget {
  final double income;

  final double savings;

  const SavingsMeter({super.key, required this.income, required this.savings});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    if (income > 0) {
      percentage = (savings / income).clamp(0, 1);
    }

    Color meterColor = Colors.green;

    if (percentage < 0.6) {
      meterColor = Colors.blue;
    }

    if (percentage < 0.3) {
      meterColor = Colors.orange;
    }

    if (percentage < 0.1) {
      meterColor = Colors.red;
    }

    return Stack(
      alignment: Alignment.center,

      children: [
        SizedBox(
          height: 100,

          width: 100,

          child: CircularProgressIndicator(
            value: percentage,

            strokeWidth: 10,

            backgroundColor: Colors.white.withOpacity(0.12),

            valueColor: AlwaysStoppedAnimation(meterColor),
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',

              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Saved',

              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}
