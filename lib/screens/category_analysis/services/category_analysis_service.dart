import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/firestore_collections.dart';
import 'category_insights_generator.dart';

class CategoryAnalysisService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const needsDetails = [
    'Groceries',
    'Fruits',
    'Vegetables',
    'Meat',
    'Dairy',
    'Fuel',
    'Bus',
    'Train',
    'Metro',
    'Parking/Tolls',
    'Vehicle Maintenance',
    'Medicine',
    'Hospital',
    'Treatment',
    'Tests / Scans',
    'Rent',
    'Hygiene',
    'Essentials',
    'Maintenance',
    'Electricity',
    'Water',
    'Gas',
    'Internet',
    'Mobile Recharge',
    'EMI',
    'Credit Card Bill',
    'CC Bills Before April 2026',
    'Bhavya',
    'Annayya',
    'Pavan',
  ];

  static const wantsDetails = [
    'Junk Food',
    'Dining',
    'Food Order',
    'Juices',
    'Coconut Water',
    'Clothes',
    'Shoes',
    'Grooming',
    'Accessories',
    'Movies',
    'Games',
    'OTT',
    'Apps',
    'Cab',
    'Plane',
    'Hotel',
    'SPA',
    'Photo',
    'Memories',
    'Shopping',
    'Gifts',
  ];

  static const futureDetails = [
    'SIP',
    'Mutual Funds',
    'Stocks',
    'Crypto',
    'FD',
    'PPF',
    'Post Office',
    'Chitti',
    'RD',
    'Term Insurance',
  ];
  Future<Map<String, dynamic>> getCategoryAnalysis({
    required DateTime startDate,
    required DateTime endDate,
    required String person,
  }) async {
    final expenseSnapshot = await firestore
        .collection(FirestoreCollections.transactions)
        .get();
    Map<String, double> categoryTotals = {};
    Map<String, double> detailTotals = {};
    Map<String, Map<String, double>> monthlyBreakdown = {};
    double totalExpense = 0;
    double totalDetailExpense = 0;
    Map<String, double> previousCategoryTotals = {};
    double previousTotalExpense = 0;
    Map<String, double> fullMonthTotals = {};
    Set<String> touchedMonths = {};
    final totalDays = endDate.difference(startDate).inDays + 1;
    final previousEnd = startDate.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(Duration(days: totalDays - 1));
    for (final doc in expenseSnapshot.docs) {
      final data = doc.data();
      // ONLY EXPENSE
      if (data['type'] != 'Expense') {
        continue;
      }
      final Timestamp timestamp = data['date'];
      final DateTime date = timestamp.toDate();
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      final isCurrentPeriod =
          !date.isBefore(startDate) && !date.isAfter(endOfDay);
      final isPreviousPeriod =
          !date.isBefore(previousStart) && !date.isAfter(previousEnd);
      final String expensePerson = data['person'] ?? '';
      if (!isCurrentPeriod && !isPreviousPeriod) {
        continue;
      }
      // PERSON FILTER
      if (person != 'All') {
        if (person == 'Both') {
          if (expensePerson != 'Both') {
            continue;
          }
        } else {
          if (expensePerson != person && expensePerson != 'Both') {
            continue;
          }
        }
      }
      final String category = data['category'] ?? 'Others';
      final String detail = data['detail'] ?? 'Others';
      final double amount = (data['amount'] ?? 0).toDouble();
      final monthKey = '${date.year}-${date.month}';
      fullMonthTotals[monthKey] = (fullMonthTotals[monthKey] ?? 0) + amount;
      if (isCurrentPeriod) {
        totalExpense += amount;
        totalDetailExpense += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        detailTotals[detail] = (detailTotals[detail] ?? 0) + amount;
        touchedMonths.add(monthKey);
        monthlyBreakdown.putIfAbsent(category, () => {});
        monthlyBreakdown[category]![monthKey] =
            (monthlyBreakdown[category]![monthKey] ?? 0) + amount;
      }
      if (isPreviousPeriod) {
        previousTotalExpense += amount;
        previousCategoryTotals[category] =
            (previousCategoryTotals[category] ?? 0) + amount;
      }
    }
    final touchedMonthValues = touchedMonths
        .map((month) => fullMonthTotals[month] ?? 0)
        .toList();
    // SORT
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // ANALYTICS
    List<Map<String, dynamic>> analytics = [];
    for (final category in sortedCategories) {
      final monthlyData = monthlyBreakdown[category.key] ?? {};
      double highest = 0;
      double lowest = 0;
      String highestMonth = '';
      String lowestMonth = '';
      if (monthlyData.isNotEmpty) {
        highest = monthlyData.values.first;
        lowest = monthlyData.values.first;
        highestMonth = monthlyData.keys.first;
        lowestMonth = monthlyData.keys.first;
        monthlyData.forEach((month, amount) {
          if (amount > highest) {
            highest = amount;
            highestMonth = month;
          }
          if (amount < lowest) {
            lowest = amount;
            lowestMonth = month;
          }
        });
      }
      final selectedMonthCount =
          ((endDate.year - startDate.year) * 12) +
          endDate.month -
          startDate.month +
          1;
      final avg = selectedMonthCount == 0
          ? 0
          : category.value / selectedMonthCount;
      final previousAmount = previousCategoryTotals[category.key] ?? 0;
      final comparisonPercentage = previousAmount == 0
          ? (category.value > 0 ? 100 : 0)
          : ((category.value - previousAmount) / previousAmount) * 100;
      analytics.add({
        'category': category.key,
        'amount': category.value,
        'percentage': totalExpense == 0
            ? 0
            : (category.value / totalExpense) * 100,
        'average': avg,
        'highest': highest,
        'lowest': lowest,
        'highestMonth': formatMonthYear(highestMonth),
        'lowestMonth': formatMonthYear(lowestMonth),
        'previousAmount': previousAmount,
        'comparisonPercentage': comparisonPercentage,
      });
    }
    final topCategory = sortedCategories.isEmpty
        ? null
        : sortedCategories.first;
    final avgCategorySpend = sortedCategories.isEmpty
        ? 0
        : totalExpense / sortedCategories.length;
    final topCategoryMonthlyAvg = analytics.isEmpty
        ? 0
        : analytics.first['average'];
    final top3Total = sortedCategories
        .take(3)
        .fold<double>(0, (sum, item) => sum + item.value);
    final spendingFocus = totalExpense == 0
        ? 0
        : ((top3Total / totalExpense) * 100);
    final totalMonths = monthlyBreakdown.values
        .expand((e) => e.keys)
        .toSet()
        .length;
    double needsAmount = 0;
    double wantsAmount = 0;
    double futureAmount = 0;
    for (final entry in detailTotals.entries) {
      if (needsDetails.contains(entry.key)) {
        needsAmount += entry.value;
      } else if (wantsDetails.contains(entry.key)) {
        wantsAmount += entry.value;
      } else if (futureDetails.contains(entry.key)) {
        futureAmount += entry.value;
      }
    }
    final needsPercentage = totalExpense == 0
        ? 0
        : (needsAmount / totalExpense) * 100;
    final wantsPercentage = totalExpense == 0
        ? 0
        : (wantsAmount / totalExpense) * 100;
    final futurePercentage = totalExpense == 0
        ? 0
        : (futureAmount / totalExpense) * 100;
    Map<String, List<Map<String, dynamic>>> trendData = {};
    // final List<Map<String, dynamic>> insights = [];
    monthlyBreakdown.forEach((category, months) {
      final sortedMonths = months.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      trendData[category] = sortedMonths
          .map((e) => {'month': e.key, 'amount': e.value})
          .toList();
    });
    final topCategoryPercentage = totalExpense == 0
        ? 0
        : ((topCategory?.value ?? 0) / totalExpense) * 100;
    final nextTopCategories = sortedCategories
        .skip(1)
        .take(3)
        .map((e) => e.key)
        .toList();

    final nextTopCategoriesTotal = sortedCategories
        .skip(1)
        .take(3)
        .fold<double>(0, (sum, e) => sum + e.value);

    final nextTopCategoriesPercentage = totalExpense == 0
        ? 0
        : (nextTopCategoriesTotal / totalExpense) * 100;

    final overallMonthlyAvg = touchedMonthValues.isEmpty
        ? 0
        : touchedMonthValues.fold<double>(0, (sum, e) => sum + e) /
              touchedMonthValues.length;
    final highestMonthSpend = touchedMonthValues.isEmpty
        ? 0
        : touchedMonthValues.reduce((a, b) => a > b ? a : b);
    final lowestMonthSpend = touchedMonthValues.isEmpty
        ? 0
        : touchedMonthValues.reduce((a, b) => a < b ? a : b);
    final insights = CategoryInsightsGenerator.generateInsights(
      analytics: analytics,
      totalExpense: totalExpense.toDouble(),
      topCategory: topCategory?.key,
      topCategoryAmount: (topCategory?.value ?? 0).toDouble(),
      topCategoryPercentage: topCategoryPercentage.toDouble(),
      spendingFocus: spendingFocus.toDouble(),
      needsPercentage: needsPercentage.toDouble(),
      wantsPercentage: wantsPercentage.toDouble(),
      futurePercentage: futurePercentage.toDouble(),
    );
    return {
      'totalExpense': totalExpense,
      'topCategory': topCategory?.key,
      'topCategoryAmount': topCategory?.value ?? 0,
      'avgCategorySpend': avgCategorySpend,
      'spendingFocus': spendingFocus,
      'needsAmount': needsAmount,
      'wantsAmount': wantsAmount,
      'futureAmount': futureAmount,
      'needsPercentage': needsPercentage,
      'wantsPercentage': wantsPercentage,
      'futurePercentage': futurePercentage,
      'monthlyTrend': trendData,
      'categories': analytics,
      'previousTotalExpense': previousTotalExpense,
      'topCategoryPercentage': topCategoryPercentage,
      'topCategoryMonthlyAvg': topCategoryMonthlyAvg,
      'overallMonthlyAvg': overallMonthlyAvg,
      'nextTopCategories': nextTopCategories,
      'nextTopCategoriesPercentage': nextTopCategoriesPercentage,
      'highestMonthSpend': highestMonthSpend,
      'lowestMonthSpend': lowestMonthSpend,
      'insights': insights,
    };
  }

  String formatMonthYear(String monthKey) {
    final parts = monthKey.split('-');

    final year = int.parse(parts[0]);

    final month = int.parse(parts[1]);

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[month]} $year';
  }
}
