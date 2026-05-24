import 'package:flutter/material.dart';

import '../constants/firestore_collections.dart';

import '../screens/setup/generic_setup_screen.dart';
import '../screens/dashboard/placeholder_screen.dart';
import '../screens/expense_limits/expense_limits_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),

            child: Align(
              alignment: Alignment.bottomLeft,

              child: Text(
                'Money Tracker',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          drawerItem(
            context,

            title: 'Expense Categories',

            screen: GenericSetupScreen(
              title: 'Expense Categories',

              collection: FirestoreCollections.expenseCategories,

              hasDetails: true,
            ),
          ),

          drawerItem(
            context,

            title: 'Income Categories',

            screen: GenericSetupScreen(
              title: 'Income Categories',

              collection: FirestoreCollections.incomeCategories,

              hasDetails: true,
            ),
          ),

          drawerItem(
            context,

            title: 'Transfer Categories',

            screen: GenericSetupScreen(
              title: 'Transfer Categories',

              collection: FirestoreCollections.transferCategories,

              hasDetails: true,
            ),
          ),

          drawerItem(
            context,

            title: 'Payment Methods',

            screen: GenericSetupScreen(
              title: 'Payment Methods',

              collection: FirestoreCollections.paymentMethods,
            ),
          ),

          drawerItem(
            context,

            title: 'Persons',

            screen: GenericSetupScreen(
              title: 'Persons',

              collection: FirestoreCollections.persons,
            ),
          ),

          drawerItem(
            context,

            title: 'Tags',

            screen: GenericSetupScreen(
              title: 'Tags',

              collection: FirestoreCollections.tags,
            ),
          ),

          drawerItem(
            context,

            title: 'Expense Limits',

            screen: const ExpenseLimitsScreen(),
          ),

          const Divider(),

          drawerItem(
            context,

            title: 'Monthly Analysis',

            screen: const PlaceholderScreen(title: 'Monthly Analysis'),
          ),

          drawerItem(
            context,

            title: 'Budgets',

            screen: const PlaceholderScreen(title: 'Budgets'),
          ),

          drawerItem(
            context,

            title: 'Goals',

            screen: const PlaceholderScreen(title: 'Goals'),
          ),

          drawerItem(
            context,

            title: 'Backup & Export',

            screen: const PlaceholderScreen(title: 'Backup & Export'),
          ),
        ],
      ),
    );
  }

  Widget drawerItem(
    BuildContext context, {

    required String title,

    required Widget screen,
  }) {
    return ListTile(
      title: Text(title),

      trailing: const Icon(Icons.arrow_forward_ios),

      onTap: () {
        Navigator.pop(context);

        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
