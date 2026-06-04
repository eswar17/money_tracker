import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../constants/firestore_collections.dart';

import '../../widgets/app_navigation_tile.dart';

import 'categories/categories_screen.dart';
import 'categories/generic_setup_screen.dart';
import 'payment_methods/payment_methods_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.setup)),
      body: ListView(
        children: [
          AppNavigationTile(
            title: AppStrings.categories,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.paymentMethods,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.persons,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenericSetupScreen(
                    title: AppStrings.persons,
                    collection: FirestoreCollections.persons,
                  ),
                ),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.tags,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenericSetupScreen(
                    title: AppStrings.tags,
                    collection: FirestoreCollections.tags,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
