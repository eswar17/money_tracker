import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../models/setup_item_model.dart';
import '../../../services/setup/setup_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
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
      appBar: AppBar(title: Text(widget.title)),

      floatingActionButton: FloatingActionButton(
        onPressed: _showItemDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<SetupItemModel>>(
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
            return const Center(child: Text(AppStrings.noItemsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(items[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemCard(SetupItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),

      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(child: Text(item.title, style: AppTextStyles.heading3)),

              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text(AppStrings.edit),
                      onTap: () {
                        Future.delayed(
                          Duration.zero,
                          () => _showItemDialog(item: item),
                        );
                      },
                    ),

                    PopupMenuItem(
                      child: const Text(AppStrings.delete),
                      onTap: () async {
                        await _setupService.deleteItem(
                          collection: widget.collection,
                          id: item.id,
                        );
                      },
                    ),
                  ];
                },
              ),
            ],
          ),

          if (widget.hasDetails && item.details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),

              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,

                children: item.details.map((detail) {
                  return Chip(label: Text(detail));
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

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

  void _showItemDialog({SetupItemModel? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');

    final detailController = TextEditingController();

    final details = item?.details.toList() ?? <String>[];

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                item == null ? AppStrings.addItem : AppStrings.editItem,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: titleController,

                      decoration: const InputDecoration(
                        labelText: AppStrings.title,
                      ),
                    ),

                    if (widget.hasDetails)
                      const SizedBox(height: AppSpacing.xl),

                    if (widget.hasDetails)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: detailController,

                              decoration: const InputDecoration(
                                labelText: AppStrings.addDetail,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          ElevatedButton(
                            onPressed: () {
                              final value = detailController.text.trim();

                              if (value.isEmpty) {
                                return;
                              }

                              setDialogState(() {
                                details.add(value);
                              });

                              detailController.clear();
                            },

                            child: const Text(AppStrings.add),
                          ),
                        ],
                      ),

                    if (widget.hasDetails)
                      const SizedBox(height: AppSpacing.lg),

                    if (widget.hasDetails && details.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,

                        children: details.map((detail) {
                          return Chip(
                            label: Text(detail),

                            deleteIcon: const Icon(Icons.close),

                            onDeleted: () {
                              setDialogState(() {
                                details.remove(detail);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text(AppStrings.cancel),
                ),

                ElevatedButton(
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

                  child: Text(
                    item == null ? AppStrings.add : AppStrings.update,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
