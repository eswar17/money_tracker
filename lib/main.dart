import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_tracker/widgets/app_drawer.dart';

import 'firebase_options.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transactions/add_transaction_screen.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  //final List<Widget> screens = const [DashboardScreen(), TransactionsScreen()];

  Future<void> openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      drawer: const AppDrawer(),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          DashboardScreen(scaffoldKey: scaffoldKey),

          TransactionsScreen(scaffoldKey: scaffoldKey),
        ],
      ),

      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'add_transaction',
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: openAddTransaction,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,

          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(28),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Row(
            children: [
              _buildTab(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
              ),

              _buildTab(
                icon: Icons.receipt_long_rounded,
                label: 'Transactions',
                selected: selectedIndex == 1,
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          curve: Curves.easeOut,

          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF16A34A).withValues(alpha: 0.10)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(18),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 24,
                color: selected
                    ? const Color(0xFF16A34A)
                    : Colors.grey.shade500,
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),

                child: selected
                    ? Row(
                        children: [
                          const SizedBox(width: 8),

                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
