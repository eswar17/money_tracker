import 'package:flutter/material.dart';

import 'monthly_dashboard_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import 'widgets/summary_card.dart';
import 'widgets/person_battle_card.dart';
import 'widgets/fun_insight_card.dart';
import 'widgets/account_analysis_card.dart';
import 'widgets/type_selector.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/monthly_insights_section.dart';

class MonthlyDashboardScreen extends StatefulWidget {
  const MonthlyDashboardScreen({super.key});

  @override
  State<MonthlyDashboardScreen> createState() => _MonthlyDashboardScreenState();
}

class _MonthlyDashboardScreenState extends State<MonthlyDashboardScreen> {
  DateTime selectedMonth = DateTime.now();

  String selectedType = 'Expense';

  final service = MonthlyDashboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Monthly Dashboard')),

      body: FutureBuilder(
        future: service.getMonthlyData(selectedMonth, selectedType),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),

            children: [
              // MONTH PICKER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                          selectedMonth.year,

                          selectedMonth.month - 1,
                        );
                      });
                    },

                    icon: const Icon(Icons.chevron_left_rounded),
                  ),

                  Text(
                    '${months[selectedMonth.month - 1]} ${selectedMonth.year}',

                    style: AppTextStyles.heading2,
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                          selectedMonth.year,

                          selectedMonth.month + 1,
                        );
                      });
                    },

                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              SummaryCard(data: data),

              const SizedBox(height: 13),

              PersonBattleCard(data: data),

              const SizedBox(height: 13),

              FunInsightCard(insight: data['funInsight']),

              const SizedBox(height: 13),

              MonthlyInsightsSection(data: data),

              const SizedBox(height: 13),

              AccountAnalysisCard(accounts: data['accounts']),

              const SizedBox(height: 13),

              TypeSelector(
                selectedType: selectedType,

                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
              ),

              const SizedBox(height: 13),

              CategoryBreakdownCard(categories: data['categories']),
            ],
          );
        },
      ),
    );
  }
}

const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
