import 'package:flutter/material.dart';

import '../../constants/firestore_collections.dart';
import 'payment_methods_screen.dart';

class SetupHomeScreen extends StatelessWidget {

  const SetupHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Setup'),
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          setupTile(

            context,

            title: 'Expense Categories',

            collection:
                FirestoreCollections
                    .expenseCategories,

            hasDetails: true,
          ),

          setupTile(

            context,

            title: 'Income Categories',

            collection:
                FirestoreCollections
                    .incomeCategories,

            hasDetails: true,
          ),

          setupTile(

            context,

            title: 'Transfer Categories',

            collection:
                FirestoreCollections
                    .transferCategories,

            hasDetails: true,
          ),

          setupTile(

            context,

            title: 'Payment Methods',

            collection:
                FirestoreCollections
                    .paymentMethods,
          ),

          setupTile(

            context,

            title: 'Persons',

            collection:
                FirestoreCollections
                    .persons,
          ),

          setupTile(

            context,

            title: 'Tags',

            collection:
                FirestoreCollections
                    .tags,
          ),
        ],
      ),
    );
  }

  Widget setupTile(

    BuildContext context, {

    required String title,

    required String collection,

    bool hasDetails = false,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: ListTile(

        title: Text(title),

        trailing:
            const Icon(Icons.chevron_right),

        onTap: () {

Navigator.push(

  context,

  MaterialPageRoute(

    builder: (_) =>
        const PaymentMethodsScreen(),
  ),
);
        },
      ),
    );
  }
}