import 'package:flutter/material.dart';
import 'package:money_tracker/models/loan_config_model.dart';
import 'package:money_tracker/screens/loans/add_edit_emi_screen.dart';
import 'package:money_tracker/services/loan_calculation_service.dart';
import 'package:money_tracker/services/loan_config_service.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final LoanCalculationService loanCalculationService =
      LoanCalculationService();

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FA),

        title: const Text(
          'EMIs & Loans',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF16A34A),

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditEmiScreen()),
          );

          setState(() {});
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          'Add EMI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loanCalculationService.calculateLoans(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final double totalOutstanding = data['totalOutstanding'];

          final double bankOutstanding = data['bankOutstanding'];

          final double friendOutstanding = data['friendOutstanding'];

          final double emiOutstanding = data['emiOutstanding'];

          List loans = List<Map<String, dynamic>>.from(data['loans']);

          int loanCount = (data['loans'] as List?)?.length ?? 0;

          if (selectedFilter != 'All') {
            loans = loans.where((loan) {
              return loan['loanType'] == selectedFilter;
            }).toList();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },

            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),

              children: [
                _topSummaryCard(totalOutstanding, loanCount),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _modernSummaryCard(
                              icon: Icons.account_balance_rounded,
                              title: 'Bank Loans',
                              amount: bankOutstanding,
                              cardColor: const Color(0xFFEFF4FF),
                              iconColor: const Color(0xFF2563EB),
                              subText:
                                  '${loans.where((e) => e['loanType'] == 'bankLoan').length} Loans',
                            ),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: _modernSummaryCard(
                              icon: Icons.phone_android_rounded,
                              title: 'EMI Purchases',
                              amount: emiOutstanding,
                              cardColor: const Color(0xFFFFF5EB),
                              iconColor: const Color(0xFFF97316),
                              subText:
                                  '${loans.where((e) => e['loanType'] == 'emiPurchase').length} Loans',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: _modernSummaryCard(
                              icon: Icons.people_alt_rounded,
                              title: 'Friend Loans',
                              amount: friendOutstanding,
                              cardColor: const Color(0xFFF5F0FF),
                              iconColor: const Color(0xFF7C3AED),
                              subText:
                                  '${loans.where((e) => e['loanType'] == 'friendLoan').length} Loans',
                            ),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: _modernSummaryCard(
                              icon: Icons.event_available_rounded,
                              title: 'Upcoming Due',
                              amount: 0,
                              cardColor: const Color(0xFFEFFBF1),
                              iconColor: const Color(0xFF16A34A),
                              customText: '05 Jul 2025',
                              subText: '1 Loan',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Text(
                    'All Loans',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 44,

                  child: ListView(
                    scrollDirection: Axis.horizontal,

                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    children: [
                      _filterChip('All'),

                      _filterChip('bankLoan'),

                      _filterChip('emiPurchase'),

                      _filterChip('friendLoan'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (loans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: Text('No Loans Found')),
                  ),

                ...loans.map((loan) => _loanCard(loan)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topSummaryCard(double amount, int loanCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: .25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Outstanding',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Across $loanCount ${loanCount == 1 ? 'Loan' : 'Loans'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/images/bank_building.png',
                height: 130,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value) {
    final selected = selectedFilter == value;

    String title = value;

    if (value == 'bankLoan') title = '🏦 Bank';
    if (value == 'emiPurchase') title = '📱 EMI';
    if (value == 'friendLoan') title = '🤝 Friends';

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loanCard(Map<String, dynamic> loan) {
    String emoji = '🏦';

    if (loan['loanType'] == 'emiPurchase') {
      emoji = '📱';
    }

    if (loan['loanType'] == 'friendLoan') {
      emoji = '🤝';
    }

    return GestureDetector(
      onTap: () async {
        if (loan['loanType'] == 'emiPurchase') {
          final config = loan['config'];

          if (config == null) {
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditEmiScreen(config: config)),
          );

          if (mounted) {
            setState(() {});
          }
        } else {
          await showLoanSettingsDialog(loan);

          if (mounted) {
            setState(() {});
          }
        }
      },

      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(8),

          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: loan['loanType'] == 'emiPurchase'
                        ? const Color(0xFFFFF1E8)
                        : loan['loanType'] == 'bankLoan'
                        ? const Color(0xFFEAF2FF)
                        : const Color(0xFFF3EDFF),
                  ),

                  child: Icon(
                    loan['loanType'] == 'emiPurchase'
                        ? Icons.phone_android_rounded
                        : loan['loanType'] == 'bankLoan'
                        ? Icons.account_balance_rounded
                        : Icons.people_alt_rounded,
                    color: loan['loanType'] == 'emiPurchase'
                        ? const Color(0xFFF97316)
                        : loan['loanType'] == 'bankLoan'
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF7C3AED),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['loanName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        loan['detailName'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),

                        decoration: BoxDecoration(
                          color: loan['loanType'] == 'emiPurchase'
                              ? const Color(0xFFFFF1E8)
                              : loan['loanType'] == 'bankLoan'
                              ? const Color(0xFFEAF2FF)
                              : const Color(0xFFF3EDFF),

                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Text(
                          loan['loanType'] == 'emiPurchase'
                              ? 'EMI Purchase'
                              : loan['loanType'] == 'bankLoan'
                              ? 'Bank Loan'
                              : 'Friend Loan',

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: loan['loanType'] == 'emiPurchase'
                                ? const Color(0xFFF97316)
                                : loan['loanType'] == 'bankLoan'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF7C3AED),
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
                      'Outstanding',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '₹${(loan['outstanding'] as double).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: loan['loanType'] == 'emiPurchase'
                            ? const Color(0xFFF97316)
                            : loan['loanType'] == 'bankLoan'
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 6),

                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 18),

            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Colors.grey.shade700,
                ),

                const SizedBox(width: 8),

                Text(
                  loan['emiAmount'] != null && (loan['emiAmount'] as num) > 0
                      ? '₹${loan['emiAmount'].toStringAsFixed(0)} / month'
                      : 'No EMI',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const Spacer(),

                if (loan['dueDay'] != null)
                  Text(
                    'Due: ${getNextDueDate(loan['dueDay'])}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLoanSettingsDialog(Map<String, dynamic> loan) async {
    final service = LoanConfigService();

    final existing = await service.getByDetailName(
      workspaceId: WorkspaceContext.currentWorkspaceId!,
      detailName: loan['detailName'],
    );

    final notesController = TextEditingController(text: existing?.notes ?? '');

    final emiAmountController = TextEditingController(
      text: (loan['emiAmount'] ?? 0).toString(),
    );

    bool reminderEnabled = existing?.reminderEnabled ?? false;

    int? dueDay = existing?.dueDay;

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,

      builder: (dialogContext) {
        String selectedLoanType = existing?.loanType ?? loan['loanType'];
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(loan['loanName']),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedLoanType,

                      decoration: const InputDecoration(labelText: 'Loan Type'),

                      items: const [
                        DropdownMenuItem(
                          value: 'bankLoan',
                          child: Text('🏦 Bank Loan'),
                        ),

                        DropdownMenuItem(
                          value: 'friendLoan',
                          child: Text('🤝 Friend Loan'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedLoanType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: dueDay,

                      decoration: const InputDecoration(labelText: 'Due Day'),

                      items: List.generate(31, (index) {
                        final day = index + 1;

                        return DropdownMenuItem(
                          value: day,
                          child: Text(day.toString()),
                        );
                      }),

                      onChanged: (value) {
                        setDialogState(() {
                          dueDay = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: emiAmountController,
                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: 'EMI Amount',
                      ),
                    ),

                    const SizedBox(height: 16),

                    SwitchListTile(
                      value: reminderEnabled,

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Reminder Enabled'),

                      onChanged: (value) {
                        setDialogState(() {
                          reminderEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: notesController,

                      maxLines: 3,

                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final model = LoanConfigModel(
                      id: existing?.id ?? loan['detailName'],

                      workspaceId: WorkspaceContext.currentWorkspaceId!,

                      loanType: selectedLoanType,

                      loanName: loan['loanName'],

                      detailName: loan['detailName'],

                      totalAmount: loan['borrowed'],

                      emiAmount:
                          double.tryParse(emiAmountController.text.trim()) ?? 0,

                      dueDay: dueDay,

                      reminderEnabled: reminderEnabled,

                      notes: notesController.text.trim(),
                    );

                    await service.saveConfig(model);

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },

                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _modernSummaryCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color cardColor,
    required Color iconColor,
    String? customText,
    String? subText,
  }) {
    return Container(
      height: 113,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 26),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            customText ?? '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: iconColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subText ?? '',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String getNextDueDate(int dueDay) {
    final now = DateTime.now();

    DateTime dueDate;

    if (now.day <= dueDay) {
      dueDate = DateTime(now.year, now.month, dueDay);
    } else {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${dueDate.day.toString().padLeft(2, '0')}/${months[dueDate.month - 1]}/${dueDate.year}';
  }
}
