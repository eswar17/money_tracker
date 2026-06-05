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

    final cardType = details.length > 0 ? details[0]['name'] ?? '' : '';

    final bankName = details.length > 1 ? details[1]['name'] ?? '' : '';

    final billingDate = details.length > 2 ? details[2]['name'] ?? '' : '';

    final dueDate = details.length > 3 ? details[3]['name'] ?? '' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Text(
                  item.title,

                  style: const TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text('Edit'),

                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          showPaymentDialog(item: item);
                        });
                      },
                    ),

                    PopupMenuItem(
                      child: const Text('Delete'),

                      onTap: () async {
                        await setupService.deleteItem(
                          collection: FirestoreCollections.paymentMethods,

                          id: item.id,
                        );
                      },
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (cardType.isNotEmpty) detailRow('Type', cardType),

          if (bankName.isNotEmpty) detailRow('Bank', bankName),

          if (billingDate.isNotEmpty) detailRow('Billing Date', billingDate),

          if (dueDate.isNotEmpty) detailRow('Due Date', dueDate),
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
