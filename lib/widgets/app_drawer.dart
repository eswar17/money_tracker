import 'package:flutter/material.dart';
import 'package:money_tracker/screens/loans/loans_screen.dart';
import '../constants/app_strings.dart';
import '../screens/setup/setup_screen.dart';
import '../screens/dashboard/placeholder_screen.dart';
import '../screens/expense_limits/expense_limits_screen.dart';
import '../screens/monthly_dashboard/monthly_dashboard_screen.dart';
import '../screens/category_analysis/category_analysis_screen.dart';
import '../screens/auth/workspace_setup_screen.dart';
import '../screens/accounts/accounts_screen.dart';
import '../core/services/auth_service.dart';
import '../services/auth/workspace_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.84,
      backgroundColor: const Color(0xFFF5F6FA),

      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                ),

                borderRadius: BorderRadius.circular(32),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -35,
                    left: -25,
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Container(
                              height: 58,
                              width: 58,

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF16A34A),
                                size: 30,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),

                                borderRadius: BorderRadius.circular(30),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),

                                  SizedBox(width: 6),

                                  Text(
                                    'Premium',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Manage money with complete clarity',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.insights_rounded,
                                color: Colors.white,
                                size: 18,
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  'Track • Analyze • Grow',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                children: [
                  _sectionTitle('SETUP'),

                  _drawerTile(
                    context,
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: AppStrings.setup,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SetupScreen()),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    icon: Icons.speed_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: AppStrings.expenseLimits,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpenseLimitsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle('ANALYSIS'),

                  _drawerTile(
                    context,
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFF10B981),
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

                  _drawerTile(
                    context,
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFF8B5CF6),
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

                  _drawerTile(
                    context,
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: AppStrings.emiLoans,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoansScreen()),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: AppStrings.accountBalance,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountsScreen(),
                        ),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFFEC4899),
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

                  const SizedBox(height: 18),

                  _sectionTitle('ACCOUNT'),

                  _drawerTile(
                    context,
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFF97316),
                    title: AppStrings.logout,
                    onTap: () async {
                      await AuthService.instance.signOut();
                    },
                  ),

                  _drawerTile(
                    context,
                    icon: Icons.exit_to_app_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: AppStrings.exitWorkspace,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 8),

      child: Text(
        title,

        style: TextStyle(
          color: Colors.grey.shade600,

          fontSize: 12,

          fontWeight: FontWeight.w800,

          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFFE5E7EB)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),

            blurRadius: 10,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),

        leading: Container(
          height: 40,
          width: 40,

          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, color: iconColor, size: 22),
        ),

        title: Text(
          title,

          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Colors.grey,
        ),

        onTap: onTap,
      ),
    );
  }
}
