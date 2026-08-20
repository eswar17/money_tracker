import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class AccountAnalysisCard extends StatefulWidget {
  final List accounts;

  const AccountAnalysisCard({super.key, required this.accounts});

  @override
  State<AccountAnalysisCard> createState() => _AccountAnalysisCardState();
}

class _AccountAnalysisCardState extends State<AccountAnalysisCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final sortedAccounts = [...widget.accounts]
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedAccounts.fold<double>(0, (sum, item) {
      return sum + item.value;
    });

    final colors = [
      Colors.blue,

      Colors.orange,

      Colors.green,

      Colors.purple,

      Colors.red,

      Colors.teal,
    ];

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
                  color: Colors.blue.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Text('💳', style: TextStyle(fontSize: 24)),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Account Analysis', style: AppTextStyles.heading3),

                  const SizedBox(height: 4),

                  Text('Monthly distribution', style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // =====================
          // EMPTY
          // =====================
          if (sortedAccounts.isEmpty)
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
                      height: expanded ? 240 : 180,

                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: expanded ? 65 : 55,

                          sectionsSpace: 4,

                          sections: List.generate(sortedAccounts.length, (
                            index,
                          ) {
                            final account = sortedAccounts[index];

                            final percent = total == 0
                                ? 0
                                : (account.value / total) * 100;

                            return PieChartSectionData(
                              value: account.value,

                              color: colors[index % colors.length],

                              radius: expanded ? 24 : 18,

                              title: expanded
                                  ? '${percent.toStringAsFixed(0)}%'
                                  : '',

                              titleStyle: const TextStyle(
                                color: Colors.white,

                                fontWeight: FontWeight.bold,

                                fontSize: 13,
                              ),
                            );
                          }),
                        ),
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
            // DETAILS
            // =====================
            if (expanded) ...[
              const SizedBox(height: 24),

              ...List.generate(sortedAccounts.length, (index) {
                final account = sortedAccounts[index];

                final percent = total == 0 ? 0 : (account.value / total) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),

                  child: Row(
                    children: [
                      Container(
                        height: 14,

                        width: 14,

                        decoration: BoxDecoration(
                          color: colors[index % colors.length],

                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          account.key,

                          style: AppTextStyles.bodyLarge,
                        ),
                      ),

                      Text(
                        '₹${account.value.toStringAsFixed(0)}',

                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        '${percent.toStringAsFixed(0)}%',

                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
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
          const Text('😴', style: TextStyle(fontSize: 42)),

          const SizedBox(height: 12),

          Text('No account activity', style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
