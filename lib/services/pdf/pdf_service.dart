import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:money_tracker/services/report/grouped_report_service.dart';
import '../../models/report/grouped_category_report.dart';
import '../../models/report/grouped_report_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/transaction_model.dart';

class PdfService {
  pw.Widget _buildCategorySection(GroupedCategoryReport category) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,

      children: [
        pw.Container(
          width: double.infinity,

          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),

          color: PdfColors.blueGrey700,

          child: pw.Text(
            category.category,

            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        _buildGroupedTableHeader(),

        ...category.rows.asMap().entries.map(
          (entry) => _buildGroupedRow(entry.value, entry.key),
        ),

        _buildCategoryTotal(category),

        pw.SizedBox(height: 18),
      ],
    );
  }

  pw.Widget _buildGroupedTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),

      color: PdfColors.blueGrey100,

      child: pw.Row(
        children: [
          _groupedHeaderCell('Detail', 2),

          _groupedHeaderCell('Tag', 1.5),

          _groupedHeaderCell('Expense', 1.2),

          _groupedHeaderCell('Settlement', 1.2),

          _groupedHeaderCell('Net Expense', 1.3),
        ],
      ),
    );
  }

  pw.Widget _buildGroupedRow(GroupedReportRow row, int index) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),

      decoration: pw.BoxDecoration(
        color: index.isEven ? PdfColors.white : PdfColors.grey100,

        border: const pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),

      child: pw.Row(
        children: [
          _groupedCell(row.detail, 2),

          _groupedCell(row.tag, 1.5),

          _groupedAmountCell(row.expense, 1.2, PdfColors.red700),

          _groupedAmountCell(row.settlement, 1.2, PdfColors.green700),

          _groupedAmountCell(
            row.netExpense,
            1.3,
            row.netExpense < 0 ? PdfColors.green700 : PdfColors.black,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryTotal(GroupedCategoryReport category) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),

      decoration: const pw.BoxDecoration(
        color: PdfColors.blue50,

        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue200)),
      ),

      child: pw.Row(
        children: [
          _groupedCell('Category Total', 2, bold: true),

          _groupedCell('', 1.5),

          _groupedAmountCell(
            category.expense,
            1.2,
            PdfColors.red700,
            bold: true,
          ),

          _groupedAmountCell(
            category.settlement,
            1.2,
            PdfColors.green700,
            bold: true,
          ),

          _groupedAmountCell(
            category.netExpense,
            1.3,
            PdfColors.black,
            bold: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGrandTotal(List<GroupedCategoryReport> report) {
    double expense = 0;

    double settlement = 0;

    double netExpense = 0;

    for (final category in report) {
      expense += category.expense;

      settlement += category.settlement;

      netExpense += category.netExpense;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),

      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey800,

        borderRadius: pw.BorderRadius.circular(6),
      ),

      child: pw.Row(
        children: [
          _grandTotalCell('GRAND TOTAL', 3.5, alignLeft: true),

          _grandTotalCell(_formatAmount(expense), 1.2),

          _grandTotalCell(_formatAmount(settlement), 1.2),

          _grandTotalCell(_formatAmount(netExpense), 1.3),
        ],
      ),
    );
  }
  // ============================================================
  // DETAILED REPORT
  // ============================================================

  Future<void> exportDetailedReport({
    required List<TransactionModel> transactions,

    required String person,

    required String category,

    required String payment,

    required String tag,

    required DateTime? startDate,

    required DateTime? endDate,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,

        margin: const pw.EdgeInsets.all(25),

        build: (context) {
          return [
            _buildHeader(),

            pw.SizedBox(height: 18),

            _buildSummary(transactions),

            pw.SizedBox(height: 25),

            // Part-2
            _buildTableHeader(),

            ...transactions.asMap().entries.map(
              (entry) => _buildTransactionRow(entry.value, entry.key),
            ),
          ];
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,

            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',

              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  // ============================================================
  // GROUPED REPORT
  // ============================================================

  Future<void> exportGroupedReport({
    required List<TransactionModel> transactions,
    required List<TransactionModel> allTransactions,
    required String person,
    required String category,
    required String payment,
    required String tag,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    // ==========================================================
    // BUILD GROUPED DATA
    // ==========================================================

    final groupedReport = GroupedReportService().build(
      transactions,
      allTransactions,
    );

    // ==========================================================
    // PDF
    // ==========================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,

        margin: const pw.EdgeInsets.all(25),

        build: (context) {
          return [
            _buildGroupedHeader(startDate: startDate, endDate: endDate),

            pw.SizedBox(height: 18),

            _buildGroupedSummary(groupedReport),

            pw.SizedBox(height: 25),

            ...groupedReport.map(
              (categoryReport) => _buildCategorySection(categoryReport),
            ),

            pw.SizedBox(height: 20),

            _buildGrandTotal(groupedReport),
          ];
        },

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,

            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',

              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  // ============================================================
  // HEADER
  // ============================================================

  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),

      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 1),
        ),
      ),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Text(
                'Money Tracker',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                'Detailed Transactions Report',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,

            children: [
              pw.Text(
                'Generated On',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.Text(
                DateFormat('dd MMM yyyy  hh:mm a').format(DateTime.now()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGroupedHeader({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    String period = 'All Transactions';

    if (startDate != null && endDate != null) {
      period =
          '${DateFormat('dd MMM yyyy').format(startDate)}'
          ' - '
          '${DateFormat('dd MMM yyyy').format(endDate)}';
    } else if (startDate != null) {
      period = 'From ${DateFormat('dd MMM yyyy').format(startDate)}';
    } else if (endDate != null) {
      period = 'Until ${DateFormat('dd MMM yyyy').format(endDate)}';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),

      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 1),
        ),
      ),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Text(
                'Money Tracker',

                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                'Grouped Expense Report',

                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),

              pw.SizedBox(height: 3),

              pw.Text(
                period,

                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,

            children: [
              pw.Text(
                'Generated On',

                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),

              pw.SizedBox(height: 3),

              pw.Text(
                DateFormat('dd MMM yyyy  hh:mm a').format(DateTime.now()),

                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGroupedSummary(List<GroupedCategoryReport> report) {
    double expense = 0;

    double settlement = 0;

    double netExpense = 0;

    for (final category in report) {
      expense += category.expense;

      settlement += category.settlement;

      netExpense += category.netExpense;
    }

    return pw.Row(
      children: [
        ExpandedCard(title: 'Expense', value: expense),

        ExpandedCard(title: 'Settlement', value: settlement),

        ExpandedCard(title: 'Net Expense', value: netExpense),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  pw.Widget _buildSummary(List<TransactionModel> transactions) {
    double income = 0;

    double expense = 0;

    double transfer = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'Income') {
        income += transaction.amount;
      } else if (transaction.type == 'Expense') {
        expense += transaction.amount;
      } else {
        transfer += transaction.amount;
      }
    }

    final double balance = income - expense;

    return pw.Row(
      children: [
        ExpandedCard(title: 'Income', value: income),

        ExpandedCard(title: 'Expense', value: expense),

        ExpandedCard(title: 'Transfer', value: transfer),

        ExpandedCard(title: 'Balance', value: balance),
      ],
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  pw.Widget _buildTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),

      color: PdfColors.blueGrey800,

      child: pw.Row(
        children: [
          _headerCell('Date', 1.2),

          _headerCell('Type', 1),

          _headerCell('Category', 1.4),

          _headerCell('Detail', 1.4),

          _headerCell('Person', 1),

          _headerCell('Payment', 1.4),

          _headerCell('Amount', 1),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION ROW
  // ============================================================

  pw.Widget _buildTransactionRow(TransactionModel transaction, int index) {
    final bool isExpense = transaction.type == 'Expense';

    final bool isIncome = transaction.type == 'Income';

    final String amountPrefix = isExpense
        ? '-'
        : isIncome
        ? '+'
        : '';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),

      decoration: pw.BoxDecoration(
        color: index.isEven ? PdfColors.white : PdfColors.grey100,

        border: const pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),

      child: pw.Row(
        children: [
          _cell(DateFormat('dd MMM yy').format(transaction.date), 1.2),

          _cell(transaction.type, 1),

          _cell(transaction.category, 1.4),

          _cell(transaction.detail, 1.4),

          _cell(transaction.person, 1),

          _cell(transaction.paymentMethod, 1.4),

          _amountCell(
            '$amountPrefix₹${transaction.amount.toStringAsFixed(0)}',
            isExpense,
            isIncome,
            1,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CELL
  // ============================================================

  pw.Widget _headerCell(String text, double flex) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),

      child: pw.Text(
        text,

        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _groupedHeaderCell(String text, double flex) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  pw.Widget _groupedCell(String text, double flex, {bool bold = false}) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Text(
        text,
        maxLines: 1,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _groupedAmountCell(
    double amount,
    double flex,
    PdfColor color, {
    bool bold = false,
  }) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          _formatAmount(amount),
          style: pw.TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  pw.Widget _grandTotalCell(
    String text,
    double flex, {
    bool alignLeft = false,
  }) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Align(
        alignment: alignLeft
            ? pw.Alignment.centerLeft
            : pw.Alignment.centerRight,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0');

    return '₹${formatter.format(amount.round())}';
  }
}

pw.Widget _cell(String text, double flex) {
  return pw.Expanded(
    flex: (flex * 10).toInt(),

    child: pw.Text(text, maxLines: 1, style: const pw.TextStyle(fontSize: 9)),
  );
}

pw.Widget _amountCell(String text, bool expense, bool income, double flex) {
  PdfColor color = PdfColors.black;

  if (expense) {
    color = PdfColors.red700;
  }

  if (income) {
    color = PdfColors.green700;
  }

  return pw.Expanded(
    flex: (flex * 10).toInt(),

    child: pw.Align(
      alignment: pw.Alignment.centerRight,

      child: pw.Text(
        text,

        style: pw.TextStyle(
          fontSize: 9,

          color: color,

          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ),
  );
}

// ============================================================
// SUMMARY CARD
// ============================================================

class ExpandedCard extends pw.StatelessWidget {
  final String title;

  final double value;

  ExpandedCard({required this.title, required this.value});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),

        padding: const pw.EdgeInsets.all(10),

        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,

          borderRadius: pw.BorderRadius.circular(6),

          border: pw.Border.all(color: PdfColors.blue200),
        ),

        child: pw.Column(
          children: [
            pw.Text(
              title,

              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),

            pw.SizedBox(height: 6),

            pw.Text(
              '₹${value.toStringAsFixed(0)}',

              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
