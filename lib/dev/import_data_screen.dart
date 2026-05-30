import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImportDataScreen extends StatelessWidget {
  const ImportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Data')),

      body: Center(
        child: ElevatedButton(
          onPressed: importAllData,

          child: const Text('IMPORT ALL DATA'),
        ),
      ),
    );
  }

  Future<void> importAllData() async {
    final firestore = FirebaseFirestore.instance;

    // =========================
    // EXPENSE CATEGORIES
    // =========================

    final expenseCategories = {
      'Food': [
        'Junk Food',
        'Dining',
        'Groceries',
        'Food Order',
        'Fruits',
        'Vegetables',
        'Meat',
        'Coconut Water',
        'Juices',
        'Dairy',
      ],

      'Transport': [
        'Fuel',
        'Cab',
        'Bus',
        'Train',
        'Plane',
        'Vehicle Maintenance',
        'Metro',
        'Parking/Tolls',
      ],

      'Health': [
        'Medicine',
        'Hospital ',
        'Treatment',
        'Supplements',
        'Tests / Scans',
      ],

      'Household': ['Rent', 'Hygiene', 'Essentials', 'Maintenance'],

      'Bills': [
        'Electricity',
        'Water',
        'Gas',
        'Internet',
        'Mobile Recharge',
        'Credit Card Bill',
      ],

      'Lifestyle': ['Clothes', 'Shoes', 'Grooming', 'Accessories'],

      'Entertainment': ['Movies', 'Games'],

      'Subscriptions': ['OTT', 'Apps'],

      'Savings': [
        'SIP',
        'Mutual Funds',
        'Stocks',
        'Crypto',
        'FD',
        'PPF',
        'Post Office',
        'Chitti',
        'RD',
      ],

      'Charity': ['Temple', 'NGO', 'Donations'],

      'Gifts': ['Gifts'],

      'Trips': [
        'Transport',
        'Hotel',
        'Food',
        'SPA',
        'Games',
        'Photo',
        'Memories',
        'Shopping',
      ],

      'Others': ['CC Bills Before April 2026', 'Miscellaneous'],

      'Loans': ['EMI', 'Bhavya', 'Annayya', 'Pavan'],

      'Insurance': ['Term', 'Health'],
    };

    for (final entry in expenseCategories.entries) {
      await firestore.collection('expense_categories').add({
        'title': entry.key,

        'details': entry.value,
      });
    }

    // =========================
    // INCOME CATEGORIES
    // =========================

    final incomeCategories = {
      'Salary': ['TechM', 'Idea Elan', 'Sodexo'],

      'Profit': ['Crypto', 'Mutual Funds'],

      'Rewards': ['Cashback', 'Scratch Cards'],
      'Savings': ['Chitti', 'Opening Balance'],
      'Loans': ['Bhavya', 'Annayya', 'Pavan'],

      'Gift': ['Latha Family', 'Eswar Family'],

      'Latha Family': ['House rent'],
      'Others': ['Miscellaneous'],
    };

    for (final entry in incomeCategories.entries) {
      await firestore.collection('income_categories').add({
        'title': entry.key,

        'details': entry.value,
      });
    }

    // =========================
    // PAYMENT METHODS
    // =========================

    final paymentMethods = [
      'Axis Flipkart',
      'Axis Rupay',
      'HDFC Credit',
      'RBL',
      'Latha Credit',
      'HDFC Debit',
      'UCO Debit',
      'Latha Debit',
      'Cash',
      'Sodexo',
      'Cred',
      'Cred Flash',
    ];

    for (final item in paymentMethods) {
      await firestore.collection('payment_methods').add({'title': item});
    }

    // =========================
    // PERSONS
    // =========================

    final persons = ['Eswar', 'Latha', 'Both', 'Parents'];

    for (final item in persons) {
      await firestore.collection('persons').add({'title': item});
    }

    // =========================
    // TAGS
    // =========================

    final tags = [
      'ENT',
      'Office',
      'Inorbit',
      'Forum',
      'AMB',
      'IKEA',
      'HomeCentre',
      'New Flat SetUp',
      'Bhadrachalam',
      'Vijayawada',
      'Neelipudi',
      'NA',
      'Full Body',
      'Others',
      'Friends',
      'Monu',
      'SDEL',
      'Coke',
      "E'La",
      'Daddy 60',
      'Hair',
      "E'La - Vizag",
    ];

    for (final item in tags) {
      await firestore.collection('tags').add({'title': item});
    }

    debugPrint('IMPORT COMPLETED');
  }
}
