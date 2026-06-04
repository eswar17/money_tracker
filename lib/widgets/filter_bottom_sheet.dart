import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../constants/firestore_collections.dart';
import '../models/filter_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_dropdown.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel currentFilter;
  final ValueChanged<FilterModel> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterModel filter;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    filter = widget.currentFilter;
    searchController.text = widget.currentFilter.searchText ?? '';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getCategoryCollection() {
    switch (filter.type) {
      case 'Income':
        return FirestoreCollections.incomeCategories;

      case 'Transfer':
        return FirestoreCollections.transferCategories;

      default:
        return FirestoreCollections.expenseCategories;
    }
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: filter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      filter = filter.copyWith(startDate: pickedDate);
    });
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: filter.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      filter = filter.copyWith(endDate: pickedDate);
    });
  }

  Widget _buildDateTile({
    required String title,
    required String emptyText,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        value != null ? '${value.day}/${value.month}/${value.year}' : emptyText,
      ),
      trailing: const Icon(Icons.calendar_month_rounded),
      onTap: onTap,
    );
  }

  Widget _buildFirestoreDropdown({
    required String hint,
    required String collection,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final itemExists = docs.any((doc) => doc.id == value);

        return AppDropdown<String>(
          hint: hint,
          icon: Icons.arrow_drop_down_circle_outlined,
          value: itemExists ? value : null,
          items: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(data['title'] ?? ''),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(AppStrings.filters, style: AppTextStyles.heading2),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            AppDropdown<String>(
              hint: AppStrings.type,
              icon: Icons.category_outlined,
              value: filter.type,
              items: const [
                DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                DropdownMenuItem(value: 'Income', child: Text('Income')),
                DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
              ],
              onChanged: (value) {
                setState(() {
                  filter = filter.copyWith(type: value, clearCategory: true);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFirestoreDropdown(
              hint: AppStrings.category,
              collection: _getCategoryCollection(),
              value: filter.categoryId,
              onChanged: (value) {
                setState(() {
                  filter = filter.copyWith(categoryId: value);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFirestoreDropdown(
              hint: AppStrings.paymentMethod,
              collection: FirestoreCollections.paymentMethods,
              value: filter.paymentMethodId,
              onChanged: (value) {
                setState(() {
                  filter = filter.copyWith(paymentMethodId: value);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFirestoreDropdown(
              hint: AppStrings.person,
              collection: FirestoreCollections.persons,
              value: filter.personId,
              onChanged: (value) {
                setState(() {
                  filter = filter.copyWith(personId: value);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFirestoreDropdown(
              hint: AppStrings.tag,
              collection: FirestoreCollections.tags,
              value: filter.tagId,
              onChanged: (value) {
                setState(() {
                  filter = filter.copyWith(tagId: value);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildDateTile(
              title: AppStrings.startDate,
              emptyText: AppStrings.selectStartDate,
              value: filter.startDate,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDateTile(
              title: AppStrings.endDate,
              emptyText: AppStrings.selectEndDate,
              value: filter.endDate,
              onTap: _pickEndDate,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: AppStrings.searchNotes,
              ),
              onChanged: (value) {
                filter = filter.copyWith(searchText: value);
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(filter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  AppStrings.applyFilters,
                  style: AppTextStyles.button,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  widget.onApply(const FilterModel());
                  Navigator.pop(context);
                },
                child: const Text(AppStrings.clearFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
