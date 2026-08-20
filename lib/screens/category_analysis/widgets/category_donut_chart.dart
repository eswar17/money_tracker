import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';

class CategoryDonutChart extends StatelessWidget {
  final List categories;

  const CategoryDonutChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        height: 320,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(28),
        ),

        child: const Center(child: Text('No Chart Data')),
      );
    }

    final topCategories = categories.take(6).toList();

    final topCategory = topCategories.first;

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================
          // HEADER
          // =====================
          Row(
            children: [
              const Text(
                'Spending Distribution',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,

                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.grey.shade100,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Text('Top Categories'),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // =====================
          // CHART
          // =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // =====================
              // DONUT
              // =====================
              Expanded(
                flex: 5,

                child: SizedBox(
                  height: 240,

                  child: Stack(
                    alignment: Alignment.center,

                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,

                          centerSpaceRadius: 70,

                          startDegreeOffset: -90,

                          sections: topCategories.map((category) {
                            return PieChartSectionData(
                              value: category['percentage'].toDouble(),

                              color: getCategoryColor(category['category']),

                              radius: 28,

                              title:
                                  '${category['percentage'].toStringAsFixed(0)}%',

                              titleStyle: const TextStyle(
                                fontSize: 12,

                                fontWeight: FontWeight.bold,

                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // =====================
                      // CENTER
                      // =====================
                      Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            getCategoryEmoji(topCategory['category']),

                            style: const TextStyle(fontSize: 30),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            topCategory['category'],

                            style: const TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${topCategory['percentage'].toStringAsFixed(0)}%',

                            style: TextStyle(
                              fontSize: 22,

                              fontWeight: FontWeight.bold,

                              color: getCategoryColor(topCategory['category']),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // =====================
              // LEGEND
              // =====================
              Expanded(
                flex: 4,

                child: Column(
                  children: topCategories.map((category) {
                    return legendTile(category);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================
  // LEGEND TILE
  // =====================

  Widget legendTile(dynamic category) {
    final color = getCategoryColor(category['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Container(
            height: 14,

            width: 14,

            decoration: BoxDecoration(
              color: color,

              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              category['category'],

              maxLines: 1,

              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹${category['amount'].toStringAsFixed(0)}',

            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // =====================
  // CATEGORY COLORS
  // =====================

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;

      case 'Transport':
        return Colors.indigo;

      case 'Health':
        return Colors.red;

      case 'Lifestyle':
        return Colors.purple;

      case 'Entertainment':
        return Colors.pink;

      case 'Savings':
        return Colors.green;

      case 'Trips':
        return Colors.cyan;

      case 'Loans':
        return Colors.deepOrange;

      case 'Bills':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  // =====================
  // EMOJIS
  // =====================

  String getCategoryEmoji(String category) {
    switch (category) {
      case 'Food':
        return '🍔';

      case 'Transport':
        return '🚕';

      case 'Health':
        return '💊';

      case 'Lifestyle':
        return '🛍';

      case 'Entertainment':
        return '🎬';

      case 'Savings':
        return '📈';

      case 'Trips':
        return '✈️';

      case 'Loans':
        return '💀';

      case 'Bills':
        return '📄';

      default:
        return '📊';
    }
  }
}
