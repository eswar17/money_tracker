import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';
import '../../../core/helpers/category_icon_helper.dart';

class CategoryBreakdownCard extends StatefulWidget {
  final List categories;

  const CategoryBreakdownCard({super.key, required this.categories});

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [...widget.categories]
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedCategories.fold<double>(0, (sum, item) {
      return sum + item.value;
    });

    final topCategory = sortedCategories.isNotEmpty
        ? sortedCategories.first
        : null;

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

            blurRadius: 18,

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
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Text('📊', style: TextStyle(fontSize: 24)),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Category Breakdown', style: AppTextStyles.heading3),

                  const SizedBox(height: 4),

                  Text(
                    'Monthly spending distribution',

                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // =====================
          // EMPTY
          // =====================
          if (sortedCategories.isEmpty)
            emptyWidget()
          else ...[
            // =====================
            // CHART
            // =====================
            GestureDetector(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                child: Column(
                  children: [
                    SizedBox(
                      height: expanded ? 260 : 200,

                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          PieChart(
                            PieChartData(
                              centerSpaceRadius: expanded ? 72 : 62,

                              sectionsSpace: 4,

                              sections: List.generate(sortedCategories.length, (
                                index,
                              ) {
                                final category = sortedCategories[index];

                                final percent = total == 0
                                    ? 0
                                    : (category.value / total) * 100;

                                return PieChartSectionData(
                                  value: category.value,

                                  color: getCategoryColor(category.key),

                                  radius: expanded ? 26 : 20,

                                  title: expanded
                                      ? '${percent.toStringAsFixed(0)}%'
                                      : '',

                                  titleStyle: const TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 12,
                                  ),
                                );
                              }),
                            ),
                          ),

                          // =====================
                          // CENTER TEXT
                          // =====================
                          if (topCategory != null)
                            Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Text('Top', style: AppTextStyles.bodySmall),

                                const SizedBox(height: 4),

                                Text(
                                  CategoryIconHelper.getEmoji(topCategory.key),

                                  style: const TextStyle(fontSize: 28),
                                ),

                                const SizedBox(height: 4),

                                SizedBox(
                                  width: 80,

                                  child: Text(
                                    topCategory.key,

                                    textAlign: TextAlign.center,

                                    maxLines: 2,

                                    overflow: TextOverflow.ellipsis,

                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          expanded ? 'Tap to collapse' : 'Tap to expand',

                          style: AppTextStyles.bodyMedium,
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // =====================
            // EXPANDED DETAILS
            // =====================
            if (expanded) ...[
              const SizedBox(height: 24),

              GridView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: sortedCategories.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  crossAxisSpacing: 14,

                  mainAxisSpacing: 14,

                  childAspectRatio: 1.1,
                ),

                itemBuilder: (context, index) {
                  final category = sortedCategories[index];

                  final percent = total == 0
                      ? 0
                      : (category.value / total) * 100;

                  return Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Row(
                          children: [
                            Container(
                              height: 12,

                              width: 12,

                              decoration: BoxDecoration(
                                color: getCategoryColor(category.key),

                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                '${CategoryIconHelper.getEmoji(category.key)} ${category.key}',

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          '₹${category.value.toStringAsFixed(0)}',

                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${percent.toStringAsFixed(0)}% of spending',

                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;

      case 'health':
        return Colors.red;

      case 'transport':
        return Colors.indigo;

      case 'entertainment':
        return Colors.pink;

      case 'shopping':
        return Colors.purple;

      case 'savings':
        return Colors.green;

      case 'crypto':
        return Colors.teal;

      default:
        return Colors.blueGrey;
    }
  }

  Widget emptyWidget() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 42)),

          const SizedBox(height: 12),

          Text('No category data', style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
