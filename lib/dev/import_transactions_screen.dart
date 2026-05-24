import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImportIncomeScreen
    extends StatelessWidget {

  const ImportIncomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Import Income',
        ),
      ),

      body: Center(

        child: ElevatedButton(

          onPressed:
              importIncomeTransactions,

          child: const Text(
            'IMPORT INCOME',
          ),
        ),
      ),
    );
  }

  Future<void>
      importIncomeTransactions()
      async {

    final firestore =
        FirebaseFirestore.instance;

    // =========================
    // LOAD CSV
    // =========================

    final rawData =
        await rootBundle.loadString(
      'assets/csv/transactions.csv',
    );

    List<List<dynamic>> csvTable =
        const CsvToListConverter()
            .convert(
      rawData,
    );

    // REMOVE HEADER
    csvTable.removeAt(0);

    // =========================
    // LOAD FIREBASE COLLECTIONS
    // =========================

    final incomeSnapshot =
        await firestore
            .collection(
              'expense_categories',
            )
            .get();

    final paymentSnapshot =
        await firestore
            .collection(
              'payment_methods',
            )
            .get();

    final personSnapshot =
        await firestore
            .collection(
              'persons',
            )
            .get();

    final tagSnapshot =
        await firestore
            .collection(
              'tags',
            )
            .get();

    // =========================
    // CREATE MAPS
    // =========================

    final Map<String, String>
        incomeCategoryMap = {};

    final Map<String, String>
        paymentMap = {};

    final Map<String, String>
        personMap = {};

    final Map<String, String>
        tagMap = {};

    // =========================
    // INCOME CATEGORIES
    // =========================

    for (final doc
        in incomeSnapshot.docs) {

      incomeCategoryMap[
              (doc['title'] as String)
                  .trim()
                  .toLowerCase()] =
          doc.id;
    }

    // =========================
    // PAYMENT METHODS
    // =========================

    for (final doc
        in paymentSnapshot.docs) {

      paymentMap[
              (doc['title'] as String)
                  .trim()
                  .toLowerCase()] =
          doc.id;
    }

    // =========================
    // PERSONS
    // =========================

    for (final doc
        in personSnapshot.docs) {

      personMap[
              (doc['title'] as String)
                  .trim()
                  .toLowerCase()] =
          doc.id;
    }

    // =========================
    // TAGS
    // =========================

    for (final doc
        in tagSnapshot.docs) {

      tagMap[
              (doc['title'] as String)
                  .trim()
                  .toLowerCase()] =
          doc.id;
    }

    // =========================
    // IMPORT TRANSACTIONS
    // =========================

    int successCount = 0;

    int skippedCount = 0;

    for (
      int i = 0;
      i < csvTable.length;
      i++
    ) {

      final row = csvTable[i];

      try {

        // =====================
        // CSV VALUES
        // =====================

        final dateString =
            row[0]
                .toString()
                .trim();

        final category =
            row[2]
                .toString()
                .trim();

        final detail =
            row[3]
                .toString()
                .trim();

        final amount =
            double.parse(
          row[4].toString(),
        );

        final paymentMethod =
            row[5]
                .toString()
                .trim();

        final tag =
            row[6]
                .toString()
                .trim();

        final person =
            row[7]
                .toString()
                .trim();

        final notes =
            row[8]
                .toString()
                .trim();

        final type =
            row[9]
                .toString()
                .trim();

        final month =
            int.parse(
          row[10]
              .toString()
              .trim() ==
                  'April'
              ? '4'
              : row[10]
                      .toString()
                      .trim() ==
                  'May'
              ? '5'
              : '1',
        );

        final year =
            int.parse(
          row[11]
              .toString()
              .trim(),
        );

        // =====================
        // ONLY INCOME
        // =====================

        if (type !=
            'Expense') {

          continue;
        }

        // =====================
        // DATE
        // =====================

        final dateParts =
            dateString.split('/');

        final date = DateTime(

          int.parse(
            dateParts[2],
          ),

          int.parse(
            dateParts[0],
          ),

          int.parse(
            dateParts[1],
          ),
        );

        // =====================
        // CATEGORY ID
        // =====================

        final categoryId =
            incomeCategoryMap[
                category
                    .toLowerCase()];

        if (categoryId ==
            null) {

          debugPrint(
            '================================',
          );

          debugPrint(
            'ROW ${i + 1} SKIPPED',
          );

          debugPrint(
            'INCOME CATEGORY NOT FOUND: $category',
          );

          debugPrint(
            'FULL ROW: $row',
          );

          debugPrint(
            '================================',
          );

          skippedCount++;

          continue;
        }

        // =====================
        // PAYMENT METHOD ID
        // =====================

        final paymentMethodId =
            paymentMap[
                paymentMethod
                    .toLowerCase()];

        if (paymentMethodId ==
            null) {

          debugPrint(
            '================================',
          );

          debugPrint(
            'ROW ${i + 1} SKIPPED',
          );

          debugPrint(
            'PAYMENT METHOD NOT FOUND: $paymentMethod',
          );

          debugPrint(
            'FULL ROW: $row',
          );

          debugPrint(
            '================================',
          );

          skippedCount++;

          continue;
        }

        // =====================
        // PERSON ID
        // =====================

        final personId =
            personMap[
                person
                    .toLowerCase()];

        if (personId ==
            null) {

          debugPrint(
            '================================',
          );

          debugPrint(
            'ROW ${i + 1} SKIPPED',
          );

          debugPrint(
            'PERSON NOT FOUND: $person',
          );

          debugPrint(
            'FULL ROW: $row',
          );

          debugPrint(
            '================================',
          );

          skippedCount++;

          continue;
        }

        // =====================
        // TAG ID
        // =====================

        final tagId =
            tagMap[
                tag
                    .toLowerCase()];

        if (tagId ==
            null) {

          debugPrint(
            '================================',
          );

          debugPrint(
            'ROW ${i + 1} SKIPPED',
          );

          debugPrint(
            'TAG NOT FOUND: $tag',
          );

          debugPrint(
            'FULL ROW: $row',
          );

          debugPrint(
            '================================',
          );

          skippedCount++;

          continue;
        }

        // =====================
        // SAVE TO FIREBASE
        // =====================

        await firestore
            .collection(
              'transactions',
            )
            .add({

          'amount': amount,

          'category': category,

          'categoryId':
              categoryId,

          'date': date,

          'detail': detail,

          'month': month,

          'notes': notes,

          'paymentMethod':
              paymentMethod,

          'paymentMethodId':
              paymentMethodId,

          'person': person,

          'personId':
              personId,

          'tag': tag,

          'tagId': tagId,

          'transferTo': null,

          'transferToId': null,

          'type': 'Expense',

          'year': year,
        });

        successCount++;

        debugPrint(
          'SUCCESS ROW ${i + 1}: $detail',
        );

      } catch (e) {

        skippedCount++;

        debugPrint(
          '================================',
        );

        debugPrint(
          'ERROR ON ROW ${i + 1}',
        );

        debugPrint(
          '$e',
        );

        debugPrint(
          'FULL ROW: $row',
        );

        debugPrint(
          '================================',
        );
      }
    }

    // =========================
    // FINAL LOGS
    // =========================

    debugPrint(
      '================================',
    );

    debugPrint(
      'INCOME IMPORT COMPLETED',
    );

    debugPrint(
      'SUCCESS: $successCount',
    );

    debugPrint(
      'SKIPPED: $skippedCount',
    );

    debugPrint(
      '================================',
    );
  }
}