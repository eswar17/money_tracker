import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_collections.dart';
import '../models/filter_model.dart';

class FilterBottomSheet
    extends StatefulWidget {

  final FilterModel currentFilter;

  final Function(FilterModel)
      onApply;

  const FilterBottomSheet({

    super.key,

    required this.currentFilter,

    required this.onApply,
  });

  @override
  State<FilterBottomSheet>
      createState() =>
          _FilterBottomSheetState();
}

class _FilterBottomSheetState
    extends State<FilterBottomSheet> {

  late FilterModel filter;

  final TextEditingController
      searchController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    filter = widget.currentFilter;

    searchController.text =
        filter.searchText ?? '';
  }

  String getCategoryCollection() {

    switch (filter.type) {

      case 'Income':
        return FirestoreCollections
            .incomeCategories;

      case 'Transfer':
        return FirestoreCollections
            .transferCategories;

      default:
        return FirestoreCollections
            .expenseCategories;
    }
  }

  Future<void> pickStartDate() async {

    final pickedDate =
        await showDatePicker(

      context: context,

      initialDate:
          filter.startDate ??
              DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {

      filter = filter.copyWith(
        startDate: pickedDate,
      );
    });
  }

  Future<void> pickEndDate() async {

    final pickedDate =
        await showDatePicker(

      context: context,

      initialDate:
          filter.endDate ??
              DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {

      filter = filter.copyWith(
        endDate: pickedDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
          const EdgeInsets.all(20),

      decoration:
          const BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      child: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Center(

              child: Text(

                'Filters',

                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TYPE
            DropdownButtonFormField<String>(

              value: filter.type,

              decoration:
                  const InputDecoration(
                labelText: 'Type',
              ),

              items: const [

                DropdownMenuItem(
                  value: 'Expense',
                  child: Text('Expense'),
                ),

                DropdownMenuItem(
                  value: 'Income',
                  child: Text('Income'),
                ),

                DropdownMenuItem(
                  value: 'Transfer',
                  child: Text('Transfer'),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(

                    type: value,

                    clearCategory: true,
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            // CATEGORY
            firestoreDropdown(

              label: 'Category',

              collection:
                  getCategoryCollection(),

              value:
                  filter.categoryId,

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(
                    categoryId: value,
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            // PAYMENT METHOD
            firestoreDropdown(

              label: 'Payment Method',

              collection:
                  FirestoreCollections
                      .paymentMethods,

              value:
                  filter.paymentMethodId,

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(
                    paymentMethodId:
                        value,
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            // PERSON
            firestoreDropdown(

              label: 'Person',

              collection:
                  FirestoreCollections
                      .persons,

              value:
                  filter.personId,

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(
                    personId: value,
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            // TAG
            firestoreDropdown(

              label: 'Tag',

              collection:
                  FirestoreCollections
                      .tags,

              value:
                  filter.tagId,

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(
                    tagId: value,
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            // START DATE
            ListTile(

              contentPadding:
                  EdgeInsets.zero,

              title: const Text(
                'Start Date',
              ),

              subtitle: Text(

                filter.startDate != null

                    ? '${filter.startDate!.day}/${filter.startDate!.month}/${filter.startDate!.year}'

                    : 'Select Start Date',
              ),

              trailing: const Icon(
                Icons.calendar_month,
              ),

              onTap: pickStartDate,
            ),

            const SizedBox(height: 10),

            // END DATE
            ListTile(

              contentPadding:
                  EdgeInsets.zero,

              title: const Text(
                'End Date',
              ),

              subtitle: Text(

                filter.endDate != null

                    ? '${filter.endDate!.day}/${filter.endDate!.month}/${filter.endDate!.year}'

                    : 'Select End Date',
              ),

              trailing: const Icon(
                Icons.calendar_month,
              ),

              onTap: pickEndDate,
            ),

            const SizedBox(height: 20),

            // SEARCH
            TextField(

              controller:
                  searchController,

              decoration:
                  const InputDecoration(
                labelText:
                    'Search Notes',
              ),

              onChanged: (value) {

                setState(() {

                  filter = filter.copyWith(
                    searchText: value,
                  );
                });
              },
            ),

            const SizedBox(height: 30),

            // APPLY BUTTON
            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: () {

                  widget.onApply(filter);

                  Navigator.pop(context);
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                ),

                child: const Text(

                  'Apply Filters',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // CLEAR BUTTON
            SizedBox(

              width: double.infinity,
              height: 55,

              child: OutlinedButton(

                onPressed: () {

                  widget.onApply(
                    const FilterModel(),
                  );

                  Navigator.pop(context);
                },

                child: const Text(
                  'Clear Filters',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget firestoreDropdown({

    required String label,

    required String collection,

    required String? value,

    required Function(String?)
        onChanged,
  }) {

    return StreamBuilder<QuerySnapshot>(

      stream:
          FirebaseFirestore.instance
              .collection(collection)
              .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {

          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final docs =
            snapshot.data!.docs;

        final itemExists = docs.any(
          (doc) => doc.id == value,
        );

        return DropdownButtonFormField<String>(

          value:
              itemExists
                  ? value
                  : null,

          decoration:
              InputDecoration(
            labelText: label,
          ),

          items:
              docs.map((doc) {

            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            return DropdownMenuItem<String>(

              value: doc.id,

              child: Text(
                data['title'],
              ),
            );

          }).toList(),

          onChanged: onChanged,
        );
      },
    );
  }
}