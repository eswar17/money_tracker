import 'package:flutter/material.dart';

import '../../models/setup_item_model.dart';
import '../../services/setup/setup_service.dart';

class GenericSetupScreen
    extends StatefulWidget {

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
  State<GenericSetupScreen>
      createState() =>
          _GenericSetupScreenState();
}

class _GenericSetupScreenState
    extends State<GenericSetupScreen> {

  final SetupService setupService =
      SetupService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          showItemDialog();
        },

        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<SetupItemModel>>(

        stream:
            setupService.getItems(
          widget.collection,
        ),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final items = snapshot.data!;

          if (items.isEmpty) {

            return const Center(
              child: Text(
                'No Items Found',
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets.all(16),

            itemCount: items.length,

            itemBuilder: (context, index) {

              final item = items[index];

              return itemCard(item);
            },
          );
        },
      ),
    );
  }

  Widget itemCard(
    SetupItemModel item,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Expanded(

                child: Text(

                  item.title,

                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              PopupMenuButton(

                itemBuilder: (context) {

                  return [

                    PopupMenuItem(

                      child:
                          const Text(
                        'Edit',
                      ),

                      onTap: () {

                        Future.delayed(

                          Duration.zero,

                          () {

                            showItemDialog(
                              item: item,
                            );
                          },
                        );
                      },
                    ),

                    PopupMenuItem(

                      child:
                          const Text(
                        'Delete',
                      ),

                      onTap:
                          () async {

                        await setupService
                            .deleteItem(

                          collection:
                              widget
                                  .collection,

                          id: item.id,
                        );
                      },
                    ),
                  ];
                },
              ),
            ],
          ),

          if (widget.hasDetails &&
              item.details.isNotEmpty)

            Padding(

              padding:
                  const EdgeInsets.only(
                top: 14,
              ),

              child: Wrap(

                spacing: 8,
                runSpacing: 8,

                children:
                    item.details.map(
                  (detail) {

                    return Chip(
                      label: Text(detail),
                    );

                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void showItemDialog({
    SetupItemModel? item,
  }) {

    final titleController =
        TextEditingController(
      text: item?.title ?? '',
    );

    final List<String> details =
        item?.details.toList() ?? [];

    final detailController =
        TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (
            context,
            setDialogState,
          ) {

            return AlertDialog(

              title: Text(

                item == null
                    ? 'Add Item'
                    : 'Edit Item',
              ),

              content:
                  SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    TextField(

                      controller:
                          titleController,

                      decoration:
                          const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),

                    if (widget.hasDetails)

                      const SizedBox(
                        height: 20,
                      ),

                    if (widget.hasDetails)

                      Row(

                        children: [

                          Expanded(

                            child: TextField(

                              controller:
                                  detailController,

                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Add Detail',
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          ElevatedButton(

                            onPressed: () {

                              final value =
                                  detailController
                                      .text
                                      .trim();

                              if (value.isEmpty) {
                                return;
                              }

                              setDialogState(() {

                                details.add(value);
                              });

                              detailController
                                  .clear();
                            },

                            child: const Text(
                              'Add',
                            ),
                          ),
                        ],
                      ),

                    if (widget.hasDetails)

                      const SizedBox(
                        height: 16,
                      ),

                    if (widget.hasDetails &&
                        details.isNotEmpty)

                      Wrap(

                        spacing: 8,
                        runSpacing: 8,

                        children:
                            details.map(
                          (detail) {

                            return Chip(

                              label:
                                  Text(detail),

                              deleteIcon:
                                  const Icon(
                                Icons.close,
                              ),

                              onDeleted: () {

                                setDialogState(() {

                                  details.remove(
                                    detail,
                                  );
                                });
                              },
                            );

                          },
                        ).toList(),
                      ),
                  ],
                ),
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(

                  onPressed: () async {

                    final title =
                        titleController.text
                            .trim();

                    if (title.isEmpty) {
                      return;
                    }

                    final setupItem =
                        SetupItemModel(

                      id: item?.id ?? '',

                      title: title,

                      details: details,
                    );

                    if (item == null) {

                      await setupService
                          .addItem(

                        collection:
                            widget.collection,

                        item: setupItem,
                      );

                    } else {

                      await setupService
                          .updateItem(

                        collection:
                            widget.collection,

                        item: setupItem,
                      );
                    }

                    if (context.mounted) {

                      Navigator.pop(
                        context,
                      );
                    }
                  },

                  child: Text(

                    item == null
                        ? 'Add'
                        : 'Update',
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