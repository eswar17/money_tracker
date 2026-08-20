import 'package:flutter/material.dart';

import '../../../constants/firestore_collections.dart';
import '../../../models/setup_item_model.dart';
import '../../../services/setup/setup_service.dart';
import '../../../services/workspace/workspace_context.dart';

class PersonsScreen extends StatefulWidget {
  const PersonsScreen({super.key});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  final SetupService _setupService = SetupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Persons',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF16A34A),

        onPressed: _showAddPersonDialog,

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          'Add Person',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            padding: const EdgeInsets.all(22),

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

            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,

                  backgroundColor: Colors.white,

                  child: Icon(
                    Icons.people_alt_rounded,
                    color: Color(0xFF16A34A),
                    size: 28,
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Dashboard Persons',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Choose who appears on dashboard',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<SetupItemModel>>(
              stream: _setupService.getItems(
                FirestoreCollections.persons,
                WorkspaceContext.currentWorkspaceId!,
              ),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final persons = snapshot.data!;

                if (persons.isEmpty) {
                  return const Center(child: Text('No Persons Found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

                  itemCount: persons.length,

                  itemBuilder: (context, index) {
                    final person = persons[index];

                    return _personCard(person);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _personCard(SetupItemModel person) {
    final int dashboardOrder = person.details.isNotEmpty
        ? (person.details.first['dashboardOrder'] ?? 0)
        : 0;

    final bool visible = dashboardOrder > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

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

      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,

            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(18),
            ),

            child: const Icon(Icons.person_rounded, color: Color(0xFF16A34A)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  person.title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visible
                          ? 'Dashboard Position #$dashboardOrder'
                          : 'Hidden from Dashboard',
                      style: TextStyle(
                        color: visible ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Switch(
                          value: visible,

                          activeThumbColor: const Color(0xFF16A34A),

                          onChanged: (value) async {
                            final updatedPerson = SetupItemModel(
                              id: person.id,
                              title: person.title,
                              workspaceId: person.workspaceId,

                              details: [
                                {
                                  'dashboardVisible': value,
                                  'dashboardOrder': value
                                      ? (dashboardOrder == 0
                                            ? 1
                                            : dashboardOrder)
                                      : 0,
                                },
                              ],
                            );

                            await _setupService.updateItem(
                              collection: FirestoreCollections.persons,
                              item: updatedPerson,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            icon: Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(Icons.more_horiz_rounded),
            ),

            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showAddPersonDialog(item: person);
                  break;

                case 'delete':
                  _confirmDelete(person);
                  break;

                case 'order':
                  _changeDashboardOrder(person);
                  break;
              }
            },

            itemBuilder: (context) {
              return const [
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
                      Icon(Icons.delete_outline, color: Colors.red),

                      SizedBox(width: 10),

                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'order',

                  child: Row(
                    children: [
                      Icon(Icons.swap_vert_rounded),

                      SizedBox(width: 10),

                      Text('Dashboard Order'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changeDashboardOrder(SetupItemModel person) async {
    int order = person.details.isNotEmpty
        ? (person.details.first['dashboardOrder'] ?? 1)
        : 1;

    final controller = TextEditingController(text: order.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dashboard Order'),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(controller.text));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final updated = SetupItemModel(
      id: person.id,
      title: person.title,
      workspaceId: person.workspaceId,

      details: [
        {'dashboardVisible': true, 'dashboardOrder': result},
      ],
    );

    await _setupService.updateItem(
      collection: FirestoreCollections.persons,
      item: updated,
    );
  }

  Future<void> _confirmDelete(SetupItemModel person) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: const Text('Delete Person?'),

          content: Text('Are you sure you want to delete "${person.title}"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

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

    if (result == true) {
      await _setupService.deleteItem(
        collection: FirestoreCollections.persons,
        id: person.id,
      );
    }
  }

  void _showAddPersonDialog({SetupItemModel? item}) {
    final controller = TextEditingController(text: item?.title ?? '');

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: Text(item == null ? 'Add Person' : 'Edit Person'),

          content: TextField(
            controller: controller,

            decoration: const InputDecoration(hintText: 'Person Name'),
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
                final title = controller.text.trim();

                if (title.isEmpty) {
                  return;
                }

                final person = SetupItemModel(
                  id: item?.id ?? '',
                  title: title,
                  details: item?.details ?? [],
                  workspaceId: WorkspaceContext.currentWorkspaceId!,
                );

                if (item == null) {
                  await _setupService.addItem(
                    collection: FirestoreCollections.persons,
                    item: person,
                  );
                } else {
                  await _setupService.updateItem(
                    collection: FirestoreCollections.persons,
                    item: person,
                  );
                }

                if (mounted) {
                  Navigator.pop(dialogContext);
                }
              },

              child: Text(item == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}
