// KEEP ALL LOGIC SAME
// ONLY REPLACE GenericSetupScreen UI WITH THIS PREMIUM VERSION

import 'package:flutter/material.dart';
import 'package:money_tracker/theme/app_spacing.dart';

import '../../../constants/app_strings.dart';
import '../../../models/setup_item_model.dart';
import '../../../services/setup/setup_service.dart';
import '../../../services/workspace/workspace_context.dart';

class GenericSetupScreen extends StatefulWidget {
  final String title;
  final String collection;
  final bool hasDetails;

  const GenericSetupScreen({
    super.key,
    required this.title,
    required this.collection,
    this.hasDetails = false,
  });

  @override
  State<GenericSetupScreen> createState() => _GenericSetupScreenState();
}

class _GenericSetupScreenState extends State<GenericSetupScreen> {
  final _setupService = SetupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,

        centerTitle: true,

        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF16A34A),

        elevation: 6,

        onPressed: _showItemDialog,

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          'Add New',
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

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.25),

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

                  child: const Icon(
                    Icons.folder_copy_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Manage and organize your setup items',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
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
                widget.collection,
                WorkspaceContext.currentWorkspaceId!,
              ),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          AppStrings.noItemsFound,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),

                  itemCount: items.length,

                  itemBuilder: (context, index) {
                    return _buildItemCard(items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(SetupItemModel item) {
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,

                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.10),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Icon(
                  Icons.folder_open_rounded,
                  color: Color(0xFF16A34A),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                tooltip: '',

                color: Colors.white,

                elevation: 12,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                offset: const Offset(0, 10),

                icon: Container(
                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.grey.shade200),
                  ),

                  child: const Icon(Icons.more_horiz_rounded, size: 18),
                ),

                onSelected: (value) async {
                  if (value == 'edit') {
                    _showItemDialog(item: item);
                  }

                  if (value == 'delete') {
                    final confirmed = await _showDeleteConfirmation(item.title);

                    if (confirmed == true) {
                      await _setupService.deleteItem(
                        collection: widget.collection,
                        id: item.id,
                      );
                    }
                  }
                },

                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: 'delete',

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (widget.hasDetails && item.details.isNotEmpty)
            const SizedBox(height: 16),

          if (widget.hasDetails && item.details.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: item.details.map((detail) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.08),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Text(
                    detail['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // KEEP YOUR EXISTING _saveItem()
  // KEEP YOUR EXISTING _showItemDialog()

  Future<void> _saveItem({
    required SetupItemModel item,
    required bool isNew,
  }) async {
    if (isNew) {
      await _setupService.addItem(collection: widget.collection, item: item);
      return;
    }

    await _setupService.updateItem(collection: widget.collection, item: item);
  }

  Future<bool?> _showDeleteConfirmation(String title) {
    return showDialog<bool>(
      context: context,

      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  height: 70,
                  width: 70,

                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Delete Item?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 10),

                Text(
                  'Are you sure you want to delete "$title"?\nThis action cannot be undone.',
                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },

                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,

                          minimumSize: const Size.fromHeight(50),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DO NOT TOUCH YOUR EXISTING DIALOG LOGIC
  // PASTE YOUR CURRENT _showItemDialog() BELOW

  void _showItemDialog({SetupItemModel? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');

    final detailController = TextEditingController();

    final details = item?.details.toList() ?? <Map<String, dynamic>>[];

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,

                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      item == null
                          ? 'Add ${widget.title}'
                          : 'Edit ${widget.title}',

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: titleController,

                      decoration: InputDecoration(
                        hintText: 'Enter title',

                        filled: true,

                        fillColor: const Color(0xFFF6F7FB),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    if (widget.hasDetails) const SizedBox(height: 20),

                    if (widget.hasDetails)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: detailController,

                              decoration: InputDecoration(
                                hintText: 'Add Detail',

                                filled: true,

                                fillColor: const Color(0xFFF6F7FB),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),

                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          SizedBox(
                            height: 52,

                            child: ElevatedButton(
                              onPressed: () {
                                final value = detailController.text.trim();

                                if (value.isEmpty) {
                                  return;
                                }

                                setDialogState(() {
                                  details.add({
                                    'id': DateTime.now().microsecondsSinceEpoch
                                        .toString(),

                                    'name': value,
                                  });
                                });

                                detailController.clear();
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: const Text(
                                'Add',

                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                    if (widget.hasDetails && details.isNotEmpty)
                      const SizedBox(height: 20),

                    if (widget.hasDetails && details.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children: details.map((detail) {
                          return GestureDetector(
                            onTap: () {
                              final controller = TextEditingController(
                                text: detail['name'],
                              );

                              showDialog(
                                context: context,

                                builder: (_) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    title: const Text('Edit Detail'),

                                    content: TextField(
                                      controller: controller,

                                      autofocus: true,
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
                                          final value = controller.text.trim();

                                          if (value.isEmpty) {
                                            return;
                                          }

                                          setDialogState(() {
                                            detail['name'] = value;
                                          });

                                          Navigator.pop(context);
                                        },

                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF16A34A,
                                ).withValues(alpha: 0.10),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Text(
                                    detail['name'] ?? '',

                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  GestureDetector(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                    dialogContext,
                                                    false,
                                                  );
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                    dialogContext,
                                                    true,
                                                  );
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm == true) {
                                        setDialogState(() {
                                          details.removeWhere(
                                            (e) => e['id'] == detail['id'],
                                          );
                                        });
                                      }
                                    },

                                    child: Container(
                                      padding: const EdgeInsets.all(2),

                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 15,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();

                          if (title.isEmpty) {
                            return;
                          }

                          final setupItem = SetupItemModel(
                            id: item?.id ?? '',

                            title: title,

                            details: details,

                            workspaceId: WorkspaceContext.currentWorkspaceId!,
                          );

                          await _saveItem(item: setupItem, isNew: item == null);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: Text(
                          item == null ? 'Create' : 'Update',

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
