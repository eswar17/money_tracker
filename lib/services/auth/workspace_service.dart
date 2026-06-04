import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_tracker/core/services/auth_service.dart';

class WorkspaceService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random();

    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<void> createWorkspace(String workspaceName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not found');
    }

    final workspaceRef = _db.collection('workspaces').doc();

    final inviteCode = generateInviteCode();

    await workspaceRef.set({
      'name': workspaceName,
      'inviteCode': inviteCode,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(user.uid).set({
      'workspaceId': workspaceRef.id,
    }, SetOptions(merge: true));

    await _seedDefaultData(workspaceRef.id);
  }

  static Future<void> _seedDefaultData(String workspaceId) async {
    final batch = _db.batch();

    await _seedExpenseCategories(batch, workspaceId);

    await _seedIncomeCategories(batch, workspaceId);

    await _seedTransferCategories(batch, workspaceId);

    await _seedPaymentMethods(batch, workspaceId);

    await _seedPersons(batch, workspaceId);

    await _seedTags(batch, workspaceId);

    await batch.commit();
  }

  static Future<void> _seedExpenseCategories(
    WriteBatch batch,
    String workspaceId,
  ) async {
    final items = {
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
        'Hospital',
        'Treatment',
        'Supplements',
        'Tests / Scans',
      ],

      'Bills': [
        'Rent',
        'Electricity',
        'Water',
        'Gas',
        'Internet',
        'Mobile Recharge',
        'Credit Card Bill',
      ],

      'Lifestyle': ['Clothes', 'Shoes', 'Grooming', 'Accessories'],

      'Shopping': ['Shopping'],

      'Entertainment': ['Movies', 'Games', 'OTT', 'Apps'],

      'Trips': [
        'Transport',
        'Hotel',
        'Food',
        'SPA',
        'Games',
        'Photo',
        'Memories',
      ],

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

      'Household': ['Essentials', 'Maintenance', 'Hygiene'],

      'Miscellaneous': ['Temple', 'NGO', 'Donations', 'Gifts', 'Miscellaneous'],
    };

    for (final item in items.entries) {
      final doc = _db.collection('expense_categories').doc();

      batch.set(doc, {
        'title': item.key,
        'details': item.value,
        'workspaceId': workspaceId,
      });
    }
  }

  static Future<void> _seedIncomeCategories(
    WriteBatch batch,
    String workspaceId,
  ) async {
    final items = [
      'Salary',
      'Business',
      'Interest',
      'Gift',
      'Refund',
      'Other Income',
    ];

    for (final title in items) {
      final doc = _db.collection('income_categories').doc();

      batch.set(doc, {
        'title': title,
        'details': [],
        'workspaceId': workspaceId,
      });
    }
  }

  static Future<void> _seedTransferCategories(
    WriteBatch batch,
    String workspaceId,
  ) async {
    final items = ['Self Transfer', 'Cash Withdrawal', 'Cash Deposit'];

    for (final title in items) {
      final doc = _db.collection('transfer_categories').doc();

      batch.set(doc, {
        'title': title,
        'details': [],
        'workspaceId': workspaceId,
      });
    }
  }

  static Future<void> _seedPaymentMethods(
    WriteBatch batch,
    String workspaceId,
  ) async {
    final doc = _db.collection('payment_methods').doc();

    batch.set(doc, {
      'title': 'Cash',
      'details': [],
      'workspaceId': workspaceId,
    });
  }

  static Future<void> _seedPersons(WriteBatch batch, String workspaceId) async {
    final doc = _db.collection('persons').doc();

    batch.set(doc, {
      'title': 'Self',
      'details': [],
      'workspaceId': workspaceId,
    });
  }

  static Future<void> _seedTags(WriteBatch batch, String workspaceId) async {
    final doc = _db.collection('tags').doc();

    batch.set(doc, {
      'title': 'General',
      'details': [],
      'workspaceId': workspaceId,
    });
  }

  static Future<void> joinWorkspace(String inviteCode) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not found');
    }

    final result = await _db
        .collection('workspaces')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    await _db.collection('users').doc(user.uid).set({
      'workspaceId': result.docs.first.id,
    }, SetOptions(merge: true));
  }

  static Future<String> getCurrentWorkspaceId() async {
    print('====================');

    print(FirebaseAuth.instance.currentUser);

    print(FirebaseAuth.instance.currentUser?.uid);

    final currentUser = AuthService.instance.currentUser;

    print(currentUser);

    print(currentUser?.uid);

    print('====================');

    if (currentUser == null) {
      throw Exception('User not found');
    }

    final userDoc = await _db.collection('users').doc(currentUser.uid).get();

    return userDoc['workspaceId'];
  }

  static Future<void> leaveWorkspace() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not found');
    }

    await _db.collection('users').doc(user.uid).update({
      'workspaceId': FieldValue.delete(),
    });
  }
}
