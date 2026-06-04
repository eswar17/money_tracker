import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../category_analysis/services/category_analysis_service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CategoryAnalysisScreen extends StatefulWidget {
  const CategoryAnalysisScreen({super.key});

  @override
  State<CategoryAnalysisScreen> createState() => _CategoryAnalysisScreenState();
}

class _CategoryAnalysisScreenState extends State<CategoryAnalysisScreen> {
  final CategoryAnalysisService _service = CategoryAnalysisService();
  Map<String, dynamic>? data;
  bool isLoading = true;
  DateTime selectedStartDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime selectedEndDate = DateTime.now();
  String selectedPerson = 'All';

  String selectedType = 'Expense';
  bool showAllCategories = false;
  bool showAllCategoryCards = false;
  String selectedSort = 'Highest Spend';
  List<Map<String, dynamic>> visibleInsights = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final result = await _service.getCategoryAnalysis(
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      person: selectedPerson,
    );
    setState(() {
      data = result;
      isLoading = false;
    });
    setState(() {
      data = result;

      final insights = List<Map<String, dynamic>>.from(
        result['insights'] ?? [],
      );

      insights.shuffle();

      visibleInsights = insights.take(4).toList();

      isLoading = false;
    });
  }

  String formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month]}';
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,

      firstDate: DateTime(2020),

      lastDate: DateTime.now(),

      initialDateRange: DateTimeRange(
        start: selectedStartDate,

        end: selectedEndDate,
      ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedStartDate = picked.start;

      selectedEndDate = picked.end;
    });

    await loadData();
  }

  Future<void> selectPerson() async {
    final result = await showModalBottomSheet<String>(
      context: context,

      backgroundColor: const Color(0xFF111827),

      builder: (_) {
        final persons = ['All', 'Eswar', 'Latha', 'Both'];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: persons.map((person) {
              return ListTile(
                title: Text(
                  person,

                  style: const TextStyle(color: Colors.white),
                ),

                onTap: () {
                  Navigator.pop(context, person);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedPerson = result;
    });

    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    final categories = List<Map<String, dynamic>>.from(
      data?['categories'] ?? [],
    );

    switch (selectedSort) {
      case 'Highest Spend':
        categories.sort(
          (a, b) => (b['amount'] as num).compareTo(a['amount'] as num),
        );
        break;

      case 'Lowest Spend':
        categories.sort(
          (a, b) => (a['amount'] as num).compareTo(b['amount'] as num),
        );
        break;

      case 'A-Z':
        categories.sort(
          (a, b) => (a['category'] ?? '').toString().compareTo(
            (b['category'] ?? '').toString(),
          ),
        );
        break;

      case 'Z-A':
        categories.sort(
          (a, b) => (b['category'] ?? '').toString().compareTo(
            (a['category'] ?? '').toString(),
          ),
        );
        break;
    }

    final visibleCategories = showAllCategoryCards
        ? categories
        : categories.take(4).toList();

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020817),

        body: Center(child: CircularProgressIndicator()),
      );
    }
    final categoryColors = [
      const Color(0xFFFF4D5A),
      const Color(0xFFFFA500),
      const Color(0xFF5EDC7A),
      const Color(0xFF4DA3FF),
      const Color(0xFF9B6BFF),
      const Color(0xFF00D1B2),
      const Color(0xFFFF7A59),
      const Color(0xFF8B5CF6),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      body: Stack(
        children: [
          // BACKGROUND GLOWS
          Positioned(
            top: -120,
            left: -80,
            child: glowCircle(size: 260, color: Colors.blue.withOpacity(0.16)),
          ),
          Positioned(
            top: 220,
            right: -100,
            child: glowCircle(
              size: 240,
              color: Colors.purple.withOpacity(0.14),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: glowCircle(size: 220, color: Colors.cyan.withOpacity(0.10)),
          ),
          // MAIN CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // BACK BUTTON
                      Container(
                        height: 26,
                        width: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      // TITLE
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Category Analysis',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ACTIONS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                selectedStartDate = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  1,
                                );

                                selectedEndDate = DateTime.now();

                                selectedPerson = 'All';

                                selectedType = 'Expense';

                                showAllCategories = false;

                                showAllCategoryCards = false;
                              });

                              await loadData();
                            },
                            child: actionButton(Icons.refresh_rounded),
                          ),
                          const SizedBox(width: 12),
                          actionButton(Icons.tune_rounded),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // FILTER BAR
                  Row(
                    children: [
                      Expanded(
                        flex: 3,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),

                          onTap: selectDateRange,

                          child: filterCard(
                            icon: Icons.calendar_today_rounded,

                            title: 'Date Range',

                            value:
                                '${formatDate(selectedStartDate)} - ${formatDate(selectedEndDate)}',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: selectPerson,
                          child: Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Person',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(0.55),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedPerson,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.92),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // HERO SUMMARY
                  Row(
                    children: [
                      Expanded(
                        child: summaryCard(
                          icon: Icons.emoji_events_rounded,
                          title: 'Top Category',
                          value:
                              '${getCategoryEmoji(data?['topCategory'] ?? '')}${data?['topCategory'] ?? '-'}',
                          subtitle1:
                              '₹${((data?['topCategoryAmount'] ?? 0) as num).toStringAsFixed(0)} • '
                              '${((data?['topCategoryPercentage'] ?? 0) as num).toStringAsFixed(0)}%',
                          subtitle2:
                              'of ₹${((data?['totalExpense'] ?? 0) as num).toStringAsFixed(0)}  ',
                          color: const Color(0xFFC86BFF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: summaryCard(
                          icon: Icons.pie_chart_rounded,
                          title: 'Next 3 Categories',
                          value:
                              '${((data?['nextTopCategoriesPercentage'] ?? 0) as num).toStringAsFixed(0)}%',
                          subtitle1:
                              ((data?['nextTopCategories'] as List?) ?? [])
                                  .isNotEmpty
                              ? (data?['nextTopCategories'] as List).first +
                                    ' •'
                              : '-',
                          subtitle2:
                              ((data?['nextTopCategories'] as List?) ?? [])
                                      .length >
                                  1
                              ? (data?['nextTopCategories'] as List)
                                    .skip(1)
                                    .join(' • ')
                              : '-',
                          color: const Color(0xFF00E5B0),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: summaryCard(
                          icon: Icons.trending_up_rounded,
                          title: 'Monthly Pattern',
                          value: formatCompactAmount(
                            (data?['overallMonthlyAvg'] ?? 0) as num,
                          ),
                          subtitle1:
                              'Highest: ${formatCompactAmount((data?['highestMonthSpend'] ?? 0) as num)} ',
                          subtitle2:
                              'Lowest: ${formatCompactAmount((data?['lowestMonthSpend'] ?? 0) as num)}',
                          color: const Color(0xFFFFB020),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // DONUT ANALYTICS
                  donutAnalyticsCard(),
                  const SizedBox(height: 17),
                  // CATEGORY OVERVIEW
                  Row(
                    children: [
                      Text(
                        'Category Overview',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          value: selectedSort,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSort = value;
                              });
                            }
                          },
                          customButton: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sort: $selectedSort',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withOpacity(0.65),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Highest Spend',
                              child: Row(
                                children: const [
                                  Text('💰'),
                                  SizedBox(width: 5),
                                  Text('Highest Spend'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Lowest Spend',
                              child: Row(
                                children: const [
                                  Text('🪙'),
                                  SizedBox(width: 5),
                                  Text('Lowest Spend'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'A-Z',
                              child: Row(
                                children: const [
                                  Text('🔤'),
                                  SizedBox(width: 10),
                                  Text('A → Z'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Z-A',
                              child: Row(
                                children: const [
                                  Text('🔠'),
                                  SizedBox(width: 10),
                                  Text('Z → A'),
                                ],
                              ),
                            ),
                          ],
                          dropdownStyleData: DropdownStyleData(
                            width: 130,
                            maxHeight: 220,
                            offset: const Offset(0, 6),
                            elevation: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2433),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(10),
                              thickness: WidgetStateProperty.all(4),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            overlayColor: WidgetStateProperty.all(
                              Colors.white.withOpacity(0.05),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.18,
                    children: visibleCategories
                        .asMap()
                        .entries
                        .map(
                          (entry) => categoryCard(
                            emoji: getCategoryEmoji(entry.value['category']),
                            title: entry.value['category'],
                            amount:
                                '₹${(entry.value['amount'] as num).toStringAsFixed(0)}',
                            percentage:
                                '${(entry.value['percentage'] as num).toStringAsFixed(0)}%',
                            trend:
                                '${(entry.value['comparisonPercentage'] as num).toStringAsFixed(0)}%',
                            avg:
                                '₹${(entry.value['average'] as num).toStringAsFixed(0)}',
                            highest:
                                '₹${(entry.value['highest'] as num).toStringAsFixed(0)}',
                            lowest:
                                '₹${(entry.value['lowest'] as num).toStringAsFixed(0)}',
                            highestMonth: entry.value['highestMonth'] ?? '',
                            lowestMonth: entry.value['lowestMonth'] ?? '',
                            color:
                                categoryColors[entry.key %
                                    categoryColors.length],
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        print("Before toggle");
                        setState(() {
                          showAllCategoryCards = !showAllCategoryCards;
                        });
                        print("After toggle");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              showAllCategoryCards
                                  ? 'Hide Categories'
                                  : 'View All Categories (${categories.length})',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              showAllCategoryCards
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.72),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  // INSIGHTS + NEEDS
                  // SMART INSIGHTS + NEEDS VS WANTS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SMART INSIGHTS
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.07),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Smart Insights',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final insights =
                                        List<Map<String, dynamic>>.from(
                                          data?['insights'] ?? [],
                                        );

                                    insights.shuffle();

                                    setState(() {
                                      visibleInsights = insights
                                          .take(4)
                                          .toList();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // INSIGHTS
                            ...visibleInsights.asMap().entries.map((entry) {
                              final insight = entry.value;

                              return Column(
                                children: [
                                  compactInsightTile(
                                    emoji: insight['emoji'],
                                    normalText: insight['text'],
                                    highlight1: '',
                                    middleText: '',
                                    highlight2: '',
                                    endText: '',
                                    color: Color(insight['color']),
                                  ),
                                  if (entry.key < visibleInsights.length - 1)
                                    divider(),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // NEEDS VS WANTS
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.07),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            const Text(
                              'Needs vs Wants vs Future',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 1),
                            // ITEMS
                            behaviorRow(
                              color: const Color(0xFF67D642),
                              title: 'Needs',
                              amount:
                                  '₹${((data?['needsAmount'] ?? 0) as num).toStringAsFixed(0)}',
                              percentage:
                                  '${((data?['needsPercentage'] ?? 0) as num).toStringAsFixed(0)}%',
                              description: 'Essential expenses you must spend',
                            ),
                            divider(),
                            behaviorRow(
                              color: const Color(0xFFFFA800),
                              title: 'Wants',
                              amount:
                                  '₹${((data?['wantsAmount'] ?? 0) as num).toStringAsFixed(0)}',
                              percentage:
                                  '${((data?['wantsPercentage'] ?? 0) as num).toStringAsFixed(0)}%',
                              description: 'Lifestyle & discretionary spending',
                            ),
                            divider(),
                            behaviorRow(
                              color: const Color(0xFF3B82F6),
                              title: 'Future',
                              amount:
                                  '₹${((data?['futureAmount'] ?? 0) as num).toStringAsFixed(0)}',
                              percentage:
                                  '${((data?['futurePercentage'] ?? 0) as num).toStringAsFixed(0)}%',
                              description: 'Investments, Savings, Insurance',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BEHAVIOR ROW
  Widget behaviorRow({
    required Color color,
    required String title,
    required String amount,
    required String percentage,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // DOT
          Container(
            height: 9,
            width: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.7), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // AMOUNT
          SizedBox(
            // width: 110,
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 7),
          // %
          SizedBox(
            // width: 50,
            child: Text(
              percentage,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMPACT INSIGHT TILE
  Widget compactInsightTile({
    required String emoji,
    required String normalText,
    required String highlight1,
    required String middleText,
    required String highlight2,
    required String endText,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EMOJI
          SizedBox(
            width: 21,
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
          //const SizedBox(width: 1),
          // TEXT
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 11,
                  // height: 1.6,
                ),
                children: [
                  TextSpan(text: normalText),
                  TextSpan(
                    text: highlight1,
                    style: TextStyle(color: color, fontWeight: FontWeight.w300),
                  ),
                  TextSpan(text: middleText),
                  TextSpan(
                    text: highlight2,
                    style: TextStyle(color: color, fontWeight: FontWeight.w300),
                  ),
                  TextSpan(text: endText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DIVIDER
  Widget divider() {
    return Divider(color: Colors.white.withOpacity(0.08), thickness: 1);
  }

  // ACTION BUTTON
  Widget actionButton(IconData icon) {
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // FILTER CARD
  Widget filterCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SUMMARY CARD
  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle1,
    required String subtitle2,
    required Color color,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.26), color.withOpacity(0.06)],
        ),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Stack(
        children: [
          // GLOW
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              height: 20,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 45,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.18),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 2),
              // TITLE
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              // VALUE
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // SUBTITLE
              Text(
                subtitle1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              // SUBTITLE
              Text(
                subtitle2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DONUT ANALYTICS CARD
  Widget donutAnalyticsCard() {
    final categories = List<Map<String, dynamic>>.from(
      data?['categories'] ?? [],
    );

    categories.sort(
      (a, b) => (b['amount'] as num).compareTo(a['amount'] as num),
    );

    List<Map<String, dynamic>> displayCategories;

    if (showAllCategories || categories.length <= 6) {
      displayCategories = categories;
    } else {
      final top5 = categories.take(5).toList();

      final others = categories.skip(5);

      final othersAmount = others.fold<double>(
        0,
        (sum, item) => sum + (item['amount'] as num).toDouble(),
      );

      final othersPercentage = others.fold<double>(
        0,
        (sum, item) => sum + (item['percentage'] as num).toDouble(),
      );

      displayCategories = [
        ...top5,

        {
          'category': 'Others',
          'amount': othersAmount,
          'percentage': othersPercentage,
        },
      ];
    }
    final colors = [
      const Color(0xFFFF4D5A),
      const Color(0xFFFFA500),
      const Color(0xFF5EDC7A),
      const Color(0xFF4DA3FF),
      const Color(0xFF9B6BFF),
      const Color(0xFF6B7280),
    ];
    final sections = displayCategories
        .asMap()
        .entries
        .map(
          (entry) => donutSection(
            (entry.value['percentage'] as num).toDouble(),
            colors[entry.key % colors.length],
          ),
        )
        .toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF101A35), const Color(0xFF0A1229)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Text(
                'Spending Distribution',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllCategories = !showAllCategories;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showAllCategories ? 'Show Top 5' : 'All Categories',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        showAllCategories
                            ? Icons.expand_less_rounded
                            : Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // BODY
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // DONUT
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 42,
                        sectionsSpace: 0,
                        startDegreeOffset: -90,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayCategories.isEmpty
                              ? '-'
                              : '${displayCategories.first['category']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayCategories.isEmpty
                              ? '0%'
                              : '${(displayCategories.first['percentage'] as num).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // LEGENDS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...displayCategories.asMap().entries.map(
                      (entry) => legendTile(
                        entry.value['category'],
                        '₹${(entry.value['amount'] as num).toStringAsFixed(0)}',
                        '${(entry.value['percentage'] as num).toStringAsFixed(0)}%',
                        colors[entry.key % colors.length],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topCenter,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Total: ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '₹${((data?['totalExpense'] ?? 0) as num).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DONUT SECTION
  PieChartSectionData donutSection(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 34,
      title: '${value.toInt()}%',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      badgeWidget: Container(
        height: 12,
        width: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.8),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  // LEGEND TILE
  Widget legendTile(String title, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 10.5,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 0),
          SizedBox(
            width: 28,
            child: Text(
              percent,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORY CARD
  Widget categoryCard({
    required String emoji,
    required String title,
    required String amount,
    required String percentage,
    required String trend,
    required String avg,
    required String highest,
    required String lowest,
    required String highestMonth,
    required String lowestMonth,
    required Color color,
  }) {
    final bool positive = trend.contains('+');
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.22), const Color(0xFF111827)],
        ),
        border: Border.all(color: color.withOpacity(0.28)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        children: [
          // TOP SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                height: 27,
                width: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.18),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 7),
              // TEXTS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$percentage of total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // TREND
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     Container(
              //       // padding: const EdgeInsets.symmetric(
              //       //   horizontal: 6,
              //       //   vertical: 4,
              //       // ),
              //       // decoration: BoxDecoration(
              //       //   color: positive
              //       //       ? Colors.red.withOpacity(0.14)
              //       //       : Colors.green.withOpacity(0.14),
              //       //   borderRadius: BorderRadius.circular(11),
              //       // ),
              //       // child: Row(
              //       //   children: [
              //       //     Icon(
              //       //       positive
              //       //           ? Icons.arrow_upward_rounded
              //       //           : Icons.arrow_downward_rounded,
              //       //       size: 7,
              //       //       color: positive
              //       //           ? Colors.redAccent
              //       //           : Colors.greenAccent,
              //       //     ),
              //       //     const SizedBox(width: 2),
              //       //     Text(
              //       //       trend,
              //       //       style: TextStyle(
              //       //         color: positive
              //       //             ? Colors.redAccent
              //       //             : Colors.greenAccent,
              //       //         fontSize: 7,
              //       //         fontWeight: FontWeight.w300,
              //       //       ),
              //       //     ),
              //       //   ],
              //       // ),
              //     ),
              //     const SizedBox(height: 4),
              //     // Text(
              //     //   'vs 1 Dec – 28 Feb',
              //     //   style: TextStyle(
              //     //     color: Colors.white.withOpacity(0.58),
              //     //     fontSize: 5,
              //     //   ),
              //     // ),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 2),
          // DIVIDER
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  color.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          // METRICS
          Row(
            children: [
              Expanded(
                child: metricColumn('Avg / Month', avg, Colors.blueAccent, ''),
              ),
              dividerLine(),
              Expanded(
                child: metricColumn(
                  'Highest',
                  highest,
                  Colors.redAccent,
                  highestMonth,
                ),
              ),
              dividerLine(),
              Expanded(
                child: metricColumn(
                  'Lowest',
                  lowest,
                  Colors.greenAccent,
                  lowestMonth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dividerLine() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget metricColumn(
    String title,
    String value,
    Color color,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.58), fontSize: 9),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              fontSize: 8,
            ),
          ),
        ],
      ],
    );
  }

  // GLOW CIRCLE
  Widget glowCircle({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 140, spreadRadius: 80)],
      ),
    );
  }

  String formatCompactAmount(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }

  String getCategoryEmoji(String category) {
    switch (category) {
      case 'Food':
        return '🍔';
      case 'Transport':
        return '🚕';
      case 'Health':
        return '🏥';
      case 'Household':
        return '🏠';
      case 'Bills':
        return '📄';
      case 'Lifestyle':
        return '🛍️';
      case 'Entertainment':
        return '🎬';
      case 'Subscriptions':
        return '📺';
      case 'Savings':
        return '🏦';
      case 'Charity':
        return '🤝';
      case 'Gifts':
        return '🎁';
      case 'Trips':
        return '✈️';
      case 'Loans':
        return '💳';
      case 'Insurance':
        return '🛡️';
      case 'Others':
        return '📦';
      default:
        return '📊';
    }
  }
}
