import '../constants/app_strings.dart';

class TransactionFilterState {
  final String selectedType;

  final String selectedCategory;

  final String selectedDetail;

  final String selectedPerson;

  final String selectedPayment;

  final String selectedTag;

  const TransactionFilterState({
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedDetail,
    required this.selectedPerson,
    required this.selectedPayment,
    required this.selectedTag,
  });

  factory TransactionFilterState.initial() {
    return const TransactionFilterState(
      selectedType: AppStrings.all,
      selectedCategory: AppStrings.all,
      selectedDetail: AppStrings.all,
      selectedPerson: AppStrings.all,
      selectedPayment: AppStrings.all,
      selectedTag: AppStrings.all,
    );
  }

  TransactionFilterState copyWith({
    String? selectedType,
    String? selectedCategory,
    String? selectedDetail,
    String? selectedPerson,
    String? selectedPayment,
    String? selectedTag,
  }) {
    return TransactionFilterState(
      selectedType: selectedType ?? this.selectedType,

      selectedCategory: selectedCategory ?? this.selectedCategory,

      selectedDetail: selectedDetail ?? this.selectedDetail,

      selectedPerson: selectedPerson ?? this.selectedPerson,

      selectedPayment: selectedPayment ?? this.selectedPayment,

      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}
