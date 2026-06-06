import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../constants/firestore_collections.dart';

import 'generic_setup_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,

        centerTitle: true,

        title: const Text(
          AppStrings.categories,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
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
                  colors: [Color(0xFFFF8A00), Color(0xFFFFB74D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.25),

                    blurRadius: 24,

                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(Icons.category_rounded, color: Colors.white, size: 38),

                  SizedBox(height: 16),

                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Organize every transaction\nwith smart categories.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Category Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 14),

            _CategoryCard(
              icon: Icons.arrow_downward_rounded,
              iconColor: Color(0xFFEF4444),
              title: AppStrings.expenseCategories,
              subtitle: 'Food, Bills, Transport, Shopping',
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

            const SizedBox(height: 12),

            _CategoryCard(
              icon: Icons.arrow_upward_rounded,
              iconColor: Color(0xFF22C55E),
              title: AppStrings.incomeCategories,
              subtitle: 'Salary, Business, Interest, Gifts',
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

            const SizedBox(height: 12),

            _CategoryCard(
              icon: Icons.compare_arrows_rounded,
              iconColor: Color(0xFF3B82F6),
              title: AppStrings.transferCategories,
              subtitle: 'Cash, Bank & Internal Transfers',
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
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryCard({
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
