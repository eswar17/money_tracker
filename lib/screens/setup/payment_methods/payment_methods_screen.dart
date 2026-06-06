import 'package:flutter/material.dart';

import '../../../models/setup_item_model.dart';
import '../../../services/setup/setup_service.dart';
import '../../../services/workspace/workspace_context.dart';
import '../../../constants/firestore_collections.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final SetupService setupService = SetupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPaymentDialog();
        },

        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<SetupItemModel>>(
        stream: setupService.getItems(
          FirestoreCollections.paymentMethods,
          WorkspaceContext.currentWorkspaceId!,
        ),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(child: Text('No Payment Methods'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: items.length,

            itemBuilder: (context, index) {
              final item = items[index];

              return paymentCard(item);
            },
          );
        },
      ),
    );
  }

  Widget paymentCard(SetupItemModel item) {
    final details = item.details;

    String getValue(String id) {
      try {
        return details.firstWhere((e) => e['id'] == id)['name'] ?? '';
      } catch (_) {
        return '';
      }
    }

    final cardType = getValue('card_type');
    final bankName = getValue('bank_name');
    final billingDate = getValue('billing_date');
    final dueDate = getValue('due_date');

    IconData icon = Icons.account_balance_wallet_rounded;

    if (cardType.toLowerCase().contains('credit')) {
      icon = Icons.credit_card_rounded;
    } else if (cardType.toLowerCase().contains('debit')) {
      icon = Icons.payments_rounded;
    } else if (cardType.toLowerCase().contains('upi')) {
      icon = Icons.qr_code_scanner_rounded;
    } else if (cardType.toLowerCase().contains('bank')) {
      icon = Icons.account_balance_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  height: 56,
                  width: 56,

                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.10),

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Icon(icon, color: const Color(0xFF16A34A), size: 28),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (cardType.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            cardType,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: '',

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  icon: Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(Icons.more_horiz_rounded, size: 18),
                  ),

                  onSelected: (value) async {
                    if (value == 'edit') {
                      showPaymentDialog(item: item);
                    }

                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),

                            title: const Text('Delete Payment Method?'),

                            content: Text(
                              'Are you sure you want to delete "${item.title}"?',
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
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await setupService.deleteItem(
                          collection: FirestoreCollections.paymentMethods,
                          id: item.id,
                        );
                      }
                    }
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',

                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: 'delete',

                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (bankName.isNotEmpty ||
                billingDate.isNotEmpty ||
                dueDate.isNotEmpty)
              const SizedBox(height: 18),

            if (bankName.isNotEmpty ||
                billingDate.isNotEmpty ||
                dueDate.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,

                children: [
                  if (bankName.isNotEmpty)
                    _infoChip(Icons.account_balance_rounded, bankName),

                  if (billingDate.isNotEmpty)
                    _infoChip(
                      Icons.calendar_month_rounded,
                      'Bill $billingDate',
                    ),

                  if (dueDate.isNotEmpty)
                    _infoChip(Icons.event_available_rounded, 'Due $dueDate'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(
        color: const Color(0xFF16A34A).withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 16, color: const Color(0xFF16A34A)),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          SizedBox(
            width: 110,

            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showPaymentDialog({SetupItemModel? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');

    final cardTypeController = TextEditingController(
      text: item != null && item.details.length > 0
          ? item.details[0]['name'] ?? ''
          : '',
    );

    final bankController = TextEditingController(
      text: item != null && item.details.length > 1
          ? item.details[1]['name'] ?? ''
          : '',
    );

    final billingController = TextEditingController(
      text: item != null && item.details.length > 2
          ? item.details[2]['name'] ?? ''
          : '',
    );

    final dueController = TextEditingController(
      text: item != null && item.details.length > 3
          ? item.details[3]['name'] ?? ''
          : '',
    );

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(
            item == null ? 'Add Payment Method' : 'Edit Payment Method',
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: titleController,

                  decoration: const InputDecoration(labelText: 'Card Name'),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: cardTypeController,

                  decoration: const InputDecoration(labelText: 'Card Type'),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: bankController,

                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: billingController,

                  decoration: const InputDecoration(labelText: 'Billing Date'),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: dueController,

                  decoration: const InputDecoration(labelText: 'Due Date'),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  return;
                }

                final details = [
                  {'id': 'card_type', 'name': cardTypeController.text.trim()},

                  {'id': 'bank_name', 'name': bankController.text.trim()},

                  {'id': 'billing_date', 'name': billingController.text.trim()},

                  {'id': 'due_date', 'name': dueController.text.trim()},
                ];

                final payment = SetupItemModel(
                  id: item?.id ?? '',
                  title: title,
                  details: details,
                  workspaceId: WorkspaceContext.currentWorkspaceId!,
                );

                if (item == null) {
                  await setupService.addItem(
                    collection: FirestoreCollections.paymentMethods,

                    item: payment,
                  );
                } else {
                  await setupService.updateItem(
                    collection: FirestoreCollections.paymentMethods,

                    item: payment,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },

              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}
