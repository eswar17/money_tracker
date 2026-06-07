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
                _topSummaryCard(totalOutstanding),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard('🏦', 'Bank', bankOutstanding),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard('📱', 'EMI', emiOutstanding),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard('🤝', 'Friends', friendOutstanding),
                      ),
                    ],
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

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Text(
                    'All Loans',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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

  Widget _topSummaryCard(double amount) {
    return Container(
      margin: const EdgeInsets.all(16),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        ),

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.25),

            blurRadius: 24,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Outstanding Debt',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 10),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String emoji, String title, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),

          const SizedBox(height: 8),

          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),

          const SizedBox(height: 4),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value) {
    final selected = selectedFilter == value;

    String title = value;

    if (value == 'bankLoan') {
      title = 'Bank';
    }

    if (value == 'emiPurchase') {
      title = 'EMI';
    }

    if (value == 'friendLoan') {
      title = 'Friends';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(title),

        selected: selected,

        onSelected: (_) {
          setState(() {
            selectedFilter = value;
          });
        },
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

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: 18,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 30)),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        loan['loanName'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      Text(
                        loan['loanType'],
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                if (loan['reminderEnabled'] == true)
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.orange,
                  ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _metric(
                    'Borrowed',
                    '₹${((loan['borrowed'] as double) == 0 ? (loan['repaid'] as double) + (loan['outstanding'] as double) : (loan['borrowed'] as double)).toStringAsFixed(0)}',
                  ),
                ),

                Expanded(
                  child: _metric(
                    'Repaid',
                    '₹${(loan['repaid'] as double).toStringAsFixed(0)}',
                  ),
                ),

                Expanded(
                  child: _metric(
                    'Outstanding',
                    '₹${(loan['outstanding'] as double).toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            if (loan['dueDay'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Text(
                    'Due on ${loan['dueDay']} of every month',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),

        const SizedBox(height: 4),

        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  Future<void> showLoanSettingsDialog(Map<String, dynamic> loan) async {
    final service = LoanConfigService();

    final existing = await service.getByDetailName(
      workspaceId: WorkspaceContext.currentWorkspaceId!,
      detailName: loan['detailName'],
    );

    final notesController = TextEditingController(text: existing?.notes ?? '');

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

                      emiAmount: 0,

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
}
