import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/services/workspace/workspace_context.dart';

import '../../../constants/app_strings.dart';
import '../../../constants/firestore_collections.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class TransactionFilters extends StatelessWidget {
  final String selectedType;

  final String selectedCategory;

  final String selectedDetail;

  final String selectedPerson;

  final String selectedPayment;

  final String selectedTag;

  final String? categoryCollection;

  final List<String> details;

  final DateTime? startDate;

  final DateTime? endDate;

  final VoidCallback onStartDateTap;

  final VoidCallback onEndDateTap;

  final VoidCallback onClearFilters;

  final ValueChanged<String> onTypeChanged;

  final ValueChanged<String> onCategoryChanged;

  final ValueChanged<String> onDetailChanged;

  final ValueChanged<String> onPersonChanged;

  final ValueChanged<String> onPaymentChanged;

  final ValueChanged<String> onTagChanged;

  const TransactionFilters({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedDetail,
    required this.selectedPerson,
    required this.selectedPayment,
    required this.selectedTag,
    required this.categoryCollection,
    required this.details,
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onClearFilters,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onDetailChanged,
    required this.onPersonChanged,
    required this.onPaymentChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _typeDropdown()),

            const SizedBox(width: 6),

            Expanded(child: _categoryDropdown()),

            const SizedBox(width: 6),

            Expanded(child: _detailDropdown()),

            const SizedBox(width: 6),

            Expanded(child: _personDropdown()),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(child: _paymentDropdown()),

            const SizedBox(width: 6),

            Expanded(
              child: _dateBox(
                label: startDate != null
                    ? '${startDate!.day}/${startDate!.month}'
                    : AppStrings.from,

                onTap: onStartDateTap,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: _dateBox(
                label: endDate != null
                    ? '${endDate!.day}/${endDate!.month}'
                    : AppStrings.to,

                onTap: onEndDateTap,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(child: _tagDropdown()),
          ],
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,

          child: GestureDetector(
            onTap: onClearFilters,

            child: Text(
              AppStrings.clearFilters,

              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _compactBox({required Widget child}) {
    return Container(
      height: 38,

      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),
      ),

      child: child,
    );
  }

  Widget _typeDropdown() {
    return _compactBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,

          isExpanded: true,

          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),

          items: const [
            DropdownMenuItem(
              value: AppStrings.all,
              child: Text(AppStrings.all),
            ),

            DropdownMenuItem(
              value: AppStrings.expense,
              child: Text(AppStrings.expense),
            ),

            DropdownMenuItem(
              value: AppStrings.income,
              child: Text(AppStrings.income),
            ),

            DropdownMenuItem(
              value: AppStrings.transfer,
              child: Text(AppStrings.transfer),
            ),
          ],

          onChanged: (value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    if (categoryCollection == null) {
      return _compactBox(
        child: Center(
          child: Text(AppStrings.category, style: AppTextStyles.bodySmall),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(categoryCollection!)
          .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _compactBox(child: const SizedBox());
        }

        final docs = snapshot.data!.docs;

        return _compactBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,

              isExpanded: true,

              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),

              items: [
                const DropdownMenuItem(
                  value: AppStrings.all,
                  child: Text(AppStrings.all),
                ),

                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
                    value: doc.id,

                    child: Text(
                      data['title'],
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }),
              ],

              onChanged: (value) {
                if (value != null) {
                  onCategoryChanged(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _detailDropdown() {
    return _compactBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDetail,

          isExpanded: true,

          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),

          items: details.isEmpty
              ? const [
                  DropdownMenuItem(
                    value: AppStrings.all,
                    child: Text(AppStrings.detail),
                  ),
                ]
              : details.map((detail) {
                  return DropdownMenuItem<String>(
                    value: detail,
                    child: Text(detail, style: AppTextStyles.bodySmall),
                  );
                }).toList(),

          onChanged: (value) {
            if (value != null) {
              onDetailChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _personDropdown() {
    return _firestoreDropdown(
      collection: FirestoreCollections.persons,
      value: selectedPerson,
      hint: AppStrings.person,
      onChanged: onPersonChanged,
    );
  }

  Widget _paymentDropdown() {
    return _firestoreDropdown(
      collection: FirestoreCollections.paymentMethods,
      value: selectedPayment,
      hint: AppStrings.payment,
      onChanged: onPaymentChanged,
    );
  }

  Widget _tagDropdown() {
    return _firestoreDropdown(
      collection: FirestoreCollections.tags,
      value: selectedTag,
      hint: AppStrings.tag,
      onChanged: onTagChanged,
    );
  }

  Widget _firestoreDropdown({
    required String collection,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('workspaceId', isEqualTo: WorkspaceContext.currentWorkspaceId)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _compactBox(child: const SizedBox());
        }

        final docs = snapshot.data!.docs;

        return _compactBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,

              isExpanded: true,

              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),

              items: [
                DropdownMenuItem(
                  value: AppStrings.all,

                  child: Text(hint, style: AppTextStyles.bodySmall),
                ),

                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
                    value: doc.id,

                    child: Text(
                      data['title'],
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }),
              ],

              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _dateBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: _compactBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Expanded(
              child: Text(
                label,

                overflow: TextOverflow.ellipsis,

                style: AppTextStyles.bodySmall,
              ),
            ),

            const Icon(Icons.calendar_today_rounded, size: 12),
          ],
        ),
      ),
    );
  }
}
