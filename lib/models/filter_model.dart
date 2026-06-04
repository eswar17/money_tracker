class FilterModel {
  final String? type;

  final String? categoryId;

  final String? paymentMethodId;

  final String? personId;

  final String? tagId;

  final DateTime? startDate;

  final DateTime? endDate;

  final String? searchText;

  const FilterModel({
    this.type,

    this.categoryId,

    this.paymentMethodId,

    this.personId,

    this.tagId,

    this.startDate,

    this.endDate,

    this.searchText,
  });

  bool get hasFilters {
    return type != null ||
        categoryId != null ||
        paymentMethodId != null ||
        personId != null ||
        tagId != null ||
        startDate != null ||
        endDate != null ||
        searchText != null;
  }

  FilterModel copyWith({
    String? type,

    String? categoryId,

    String? paymentMethodId,

    String? personId,

    String? tagId,

    DateTime? startDate,

    DateTime? endDate,

    String? searchText,

    bool clearType = false,

    bool clearCategory = false,

    bool clearPaymentMethod = false,

    bool clearPerson = false,

    bool clearTag = false,

    bool clearStartDate = false,

    bool clearEndDate = false,

    bool clearSearch = false,
  }) {
    return FilterModel(
      type: clearType ? null : type ?? this.type,

      categoryId: clearCategory ? null : categoryId ?? this.categoryId,

      paymentMethodId: clearPaymentMethod
          ? null
          : paymentMethodId ?? this.paymentMethodId,

      personId: clearPerson ? null : personId ?? this.personId,

      tagId: clearTag ? null : tagId ?? this.tagId,

      startDate: clearStartDate ? null : startDate ?? this.startDate,

      endDate: clearEndDate ? null : endDate ?? this.endDate,

      searchText: clearSearch ? null : searchText ?? this.searchText,
    );
  }
}
