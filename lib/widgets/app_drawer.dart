import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

import '../widgets/app_navigation_tile.dart';

import '../screens/setup/setup_screen.dart';
import '../screens/dashboard/placeholder_screen.dart';
import '../screens/expense_limits/expense_limits_screen.dart';
import '../screens/monthly_dashboard/monthly_dashboard_screen.dart';
import '../screens/category_analysis/category_analysis_screen.dart';
import '../screens/auth/workspace_setup_screen.dart';

import '../core/services/auth_service.dart';
import '../services/auth/workspace_service.dart';

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
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          AppNavigationTile(
            title: AppStrings.setup,
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.expenseLimits,
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseLimitsScreen()),
              );
            },
          ),

          const Divider(),

          AppNavigationTile(
            title: AppStrings.monthlyDashboard,
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MonthlyDashboardScreen(),
                ),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.categoryAnalysis,
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryAnalysisScreen(),
                ),
              );
            },
          ),

          AppNavigationTile(
            title: AppStrings.goals,
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PlaceholderScreen(title: AppStrings.goals),
                ),
              );
            },
          ),

          ListTile(
            title: const Text(AppStrings.logout),
            onTap: () async {
              await AuthService.instance.signOut();
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded),
            title: const Text(AppStrings.exitWorkspace),
            onTap: () async {
              await WorkspaceService.leaveWorkspace();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkspaceSetupScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
