import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseLimitsScreen
    extends StatefulWidget {

  const ExpenseLimitsScreen({
    super.key,
  });

  @override
  State<ExpenseLimitsScreen>
      createState() =>
          _ExpenseLimitsScreenState();
}

class _ExpenseLimitsScreenState
    extends State<
        ExpenseLimitsScreen> {

  final FirebaseFirestore
      firestore =
      FirebaseFirestore.instance;

  Future<void> openLimitSheet({

    DocumentSnapshot?
        document,
  }) async {

    final amountController =
        TextEditingController(

      text: document != null

          ? document['limit']
              .toString()

          : '',
    );

    String? selectedCategory;

    String? selectedCategoryId;

    String? selectedPerson;

    String? selectedPersonId;

    if (document != null) {

      selectedCategory =
          document['category'];

      selectedCategoryId =
          document['categoryId'];

      selectedPerson =
          document['person'];

      selectedPersonId =
          document['personId'];
    }

    final expenseCategories =
        await firestore
            .collection(
              'expense_categories',
            )
            .get();

    final persons =
        await firestore
            .collection(
              'persons',
            )
            .get();

    if (!mounted) {

      return;
    }

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (context) {

        return StatefulBuilder(

          builder:
              (context, setSheetState) {

            return Container(

              padding:
                  EdgeInsets.only(

                left: 20,

                right: 20,

                top: 24,

                bottom:
                    MediaQuery.of(
                          context,
                        )
                        .viewInsets
                        .bottom +
                        24,
              ),

              decoration:
                  const BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(

                  top:
                      Radius.circular(
                    28,
                  ),
                ),
              ),

              child: Column(

                mainAxisSize:
                    MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    document == null

                        ? 'Add Expense Limit'

                        : 'Edit Expense Limit',

                    style:
                        const TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =====================
                  // CATEGORY
                  // =====================

                  DropdownButtonFormField<
                      String>(

                    value:
                        selectedCategory,

                    decoration:
                        InputDecoration(

                      labelText:
                          'Expense Category',

                      filled: true,

                      fillColor:
                          const Color(
                        0xFFF5F7FB,
                      ),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    items:
                        expenseCategories
                            .docs
                            .map(

                      (doc) {

                        return DropdownMenuItem<String>(

                          value:
                              doc['title'],

                          child: Text(
                            doc['title'],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {

                      final doc =
                          expenseCategories
                              .docs
                              .firstWhere(

                        (element) {

                          return element[
                                  'title'] ==
                              value;
                        },
                      );

                      setSheetState(() {

                        selectedCategory =
                            value;

                        selectedCategoryId =
                            doc.id;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =====================
                  // LIMIT
                  // =====================

                  TextField(

                    controller:
                        amountController,

                    keyboardType:
                        TextInputType
                            .number,

                    decoration:
                        InputDecoration(

                      labelText:
                          'Limit Amount',

                      filled: true,

                      fillColor:
                          const Color(
                        0xFFF5F7FB,
                      ),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =====================
                  // PERSON
                  // =====================

                  DropdownButtonFormField<
                      String>(

                    value:
                        selectedPerson,

                    decoration:
                        InputDecoration(

                      labelText:
                          'Person',

                      filled: true,

                      fillColor:
                          const Color(
                        0xFFF5F7FB,
                      ),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    items:
                        persons.docs.map(

                      (doc) {

                        return DropdownMenuItem<String>(

                          value:
                              doc['title'],

                          child: Text(
                            doc['title'],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {

                      final doc =
                          persons.docs
                              .firstWhere(

                        (element) {

                          return element[
                                  'title'] ==
                              value;
                        },
                      );

                      setSheetState(() {

                        selectedPerson =
                            value;

                        selectedPersonId =
                            doc.id;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // =====================
                  // SAVE
                  // =====================

                  SizedBox(

                    width:
                        double.infinity,

                    child:
                        ElevatedButton(

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            Colors.black,

                        padding:
                            const EdgeInsets.symmetric(

                          vertical: 16,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),

                      onPressed:
                          () async {

                        if (selectedCategory ==
                                null ||

                            selectedPerson ==
                                null ||

                            amountController
                                .text
                                .trim()
                                .isEmpty) {

                          return;
                        }

                        final limit =
                            double.parse(

                          amountController
                              .text
                              .trim(),
                        );

                        final docId =

                            '${selectedCategoryId}_${selectedPersonId}';

                        await firestore
                            .collection(
                              'expense_limits',
                            )
                            .doc(
                              docId,
                            )
                            .set({

                          'category':
                              selectedCategory,

                          'categoryId':
                              selectedCategoryId,

                          'person':
                              selectedPerson,

                          'personId':
                              selectedPersonId,

                          'limit':
                              limit,
                        });

                        if (!mounted) {

                          return;
                        }

                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Text(

                        'Save',

                        style: TextStyle(

                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F7FB,
      ),

      appBar: AppBar(

        title: const Text(
          'Expense Limits',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.black,

        onPressed: () {

          openLimitSheet();
        },

        child: const Icon(

          Icons.add_rounded,

          color: Colors.white,
        ),
      ),

      body: StreamBuilder<

          QuerySnapshot>(

        stream:
            firestore
                .collection(
                  'expense_limits',
                )
                .snapshots(),

        builder:
            (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return const Center(

              child: Text(
                'No Expense Limits',
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets.all(
              18,
            ),

            itemCount:
                docs.length,

            itemBuilder:
                (context, index) {

              final document =
                  docs[index];

              return Container(

                margin:
                    const EdgeInsets.only(
                  bottom: 14,
                ),

                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration:
                    BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),

                child: Row(

                  children: [

                    Container(

                      height: 52,

                      width: 52,

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.orange
                                .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),

                      child: const Center(

                        child: Text(
                          '💸',
                          style:
                              TextStyle(
                            fontSize:
                                22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(

                            document[
                                'category'],

                            style:
                                const TextStyle(

                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            document[
                                'person'],

                            style:
                                TextStyle(

                              color:
                                  Colors.grey
                                      .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,

                      children: [

                        Text(

                          '₹${document['limit'].toStringAsFixed(0)}',

                          style:
                              const TextStyle(

                            fontSize: 18,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        GestureDetector(

                          onTap: () {

                            openLimitSheet(
                              document:
                                  document,
                            );
                          },

                          child: const Icon(
                            Icons
                                .edit_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}