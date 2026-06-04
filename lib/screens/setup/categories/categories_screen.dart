import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../constants/firestore_collections.dart';

import '../../../widgets/app_navigation_tile.dart';

import 'generic_setup_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: ListView(
        children: [
          AppNavigationTile(
            title: AppStrings.expenseCategories,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenericSetupScreen(
                    title: AppStrings.expenseCategories,
                    collection: FirestoreCollections.expenseCategories,
                    hasDetails: true,
                  ),
                ),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.incomeCategories,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenericSetupScreen(
                    title: AppStrings.incomeCategories,
                    collection: FirestoreCollections.incomeCategories,
                    hasDetails: true,
                  ),
                ),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.transferCategories,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenericSetupScreen(
                    title: AppStrings.transferCategories,
                    collection: FirestoreCollections.transferCategories,
                    hasDetails: true,
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
