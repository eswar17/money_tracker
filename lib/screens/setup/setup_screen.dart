import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../constants/firestore_collections.dart';

import 'categories/categories_screen.dart';
import 'categories/generic_setup_screen.dart';
import 'payment_methods/payment_methods_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,

        centerTitle: true,

        title: const Text(
          AppStrings.setup,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.settings_suggest_rounded,
                    color: Colors.white,
                    size: 38,
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Workspace Setup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Manage categories, payment methods,\npersons and tags.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 14),

            _SetupCard(
              icon: Icons.category_rounded,
              iconColor: Colors.orange,
              title: AppStrings.categories,
              subtitle: 'Expense, Income & Transfer Categories',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _SetupCard(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: Colors.blue,
              title: AppStrings.paymentMethods,
              subtitle: 'Cash, Bank, UPI & Cards',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentMethodsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _SetupCard(
              icon: Icons.people_alt_rounded,
              iconColor: Colors.deepPurple,
              title: AppStrings.persons,
              subtitle: 'Family, Friends & Contacts',
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

            const SizedBox(height: 12),

            _SetupCard(
              icon: Icons.sell_rounded,
              iconColor: Colors.teal,
              title: AppStrings.tags,
              subtitle: 'Custom labels for transactions',
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
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SetupCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,

                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: iconColor, size: 28),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 38,
                width: 38,

                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(Icons.arrow_forward_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
