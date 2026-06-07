import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/loan_config_model.dart';
import '../../services/loan_config_service.dart';
import '../../services/workspace/workspace_context.dart';

class AddEditEmiScreen extends StatefulWidget {
  final LoanConfigModel? config;

  const AddEditEmiScreen({super.key, this.config});

  @override
  State<AddEditEmiScreen> createState() => _AddEditEmiScreenState();
}

class _AddEditEmiScreenState extends State<AddEditEmiScreen> {
  final LoanConfigService service = LoanConfigService();

  final loanNameController = TextEditingController();

  final totalAmountController = TextEditingController();

  final emiAmountController = TextEditingController();

  final notesController = TextEditingController();

  String? selectedDetail;

  int? dueDay;

  bool reminderEnabled = true;

  @override
  void initState() {
    super.initState();

    final config = widget.config;

    if (config != null) {
      loanNameController.text = config.loanName;

      totalAmountController.text = config.totalAmount.toString();

      emiAmountController.text = config.emiAmount.toString();

      notesController.text = config.notes;

      selectedDetail = config.detailName;

      dueDay = config.dueDay;

      reminderEnabled = config.reminderEnabled;
    }
  }

  Future<void> save() async {
    if (selectedDetail == null ||
        loanNameController.text.trim().isEmpty ||
        totalAmountController.text.trim().isEmpty) {
      return;
    }

    final model = LoanConfigModel(
      id: widget.config?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),

      workspaceId: WorkspaceContext.currentWorkspaceId!,

      loanType: 'emiPurchase',

      loanName: loanNameController.text.trim(),

      detailName: selectedDetail!,

      totalAmount: double.parse(totalAmountController.text),

      emiAmount: double.tryParse(emiAmountController.text) ?? 0,

      dueDay: dueDay,

      reminderEnabled: reminderEnabled,

      notes: notesController.text.trim(),
    );

    await service.saveConfig(model);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> deleteEmi() async {
    if (widget.config == null) {
      return;
    }

    await service.deleteConfig(widget.config!.id);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: Text(widget.config == null ? 'Add EMI' : 'Edit EMI'),

        actions: [
          if (widget.config != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.red),

              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,

                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete EMI?'),

                      content: const Text(
                        'This EMI configuration will be deleted.',
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },

                          child: const Text('Cancel'),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },

                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await deleteEmi();
                }
              },
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            _card(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('expense_categories')
                    .where(
                      'workspaceId',
                      isEqualTo: WorkspaceContext.currentWorkspaceId,
                    )
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final categories = snapshot.data!.docs;

                  DocumentSnapshot? loanCategory;

                  for (final doc in categories) {
                    if (doc['title'] == 'EMI') {
                      loanCategory = doc;
                      break;
                    }
                  }

                  if (loanCategory == null) {
                    return const Text('EMI category not found');
                  }

                  final details = List<Map<String, dynamic>>.from(
                    loanCategory['details'] ?? [],
                  );

                  return DropdownButtonFormField<String>(
                    value: selectedDetail,

                    decoration: const InputDecoration(labelText: 'Loan Detail'),

                    items: details.map<DropdownMenuItem<String>>((detail) {
                      return DropdownMenuItem<String>(
                        value: detail['name'].toString(),
                        child: Text(detail['name'].toString()),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedDetail = value;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            _textField(controller: loanNameController, label: 'Loan Name'),

            const SizedBox(height: 14),

            _textField(
              controller: totalAmountController,
              label: 'Total Amount',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 14),

            _textField(
              controller: emiAmountController,
              label: 'Monthly EMI',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 14),

            _card(
              child: DropdownButtonFormField<int>(
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
                  setState(() {
                    dueDay = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: SwitchListTile(
                value: reminderEnabled,

                contentPadding: EdgeInsets.zero,

                title: const Text('Reminder Enabled'),

                onChanged: (value) {
                  setState(() {
                    reminderEnabled = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 14),

            _textField(
              controller: notesController,
              label: 'Notes',
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              height: 54,

              child: ElevatedButton(
                onPressed: save,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                ),

                child: Text(
                  widget.config == null ? 'Create EMI' : 'Update EMI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return _card(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,

        decoration: InputDecoration(border: InputBorder.none, hintText: label),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: child,
    );
  }
}
