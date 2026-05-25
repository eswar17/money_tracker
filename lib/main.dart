import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transactions/add_transaction_screen.dart';
import 'constants/firestore_collections.dart';
import 'screens/setup/generic_setup_screen.dart';
import 'screens/setup/payment_methods_screen.dart';
// import 'dev/import_data_screen.dart';
// import 'dev/import_transactions_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(

    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  runApp(
    const MoneyTrackerApp(),
  );
}

class MoneyTrackerApp
    extends StatelessWidget {

  const MoneyTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title: 'Money Tracker',

      theme: ThemeData(

        primarySwatch:
            Colors.green,

        scaffoldBackgroundColor:
            const Color(
          0xFFF5F6FA,
        ),

        appBarTheme:
            const AppBarTheme(

          backgroundColor:
              Colors.white,

          elevation: 0,

          centerTitle: true,

          iconTheme: IconThemeData(
            color: Colors.black,
          ),

          titleTextStyle:
              TextStyle(

            color: Colors.black,

            fontSize: 20,

            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      home:
          const MainNavigationScreen(), //MainNavigationScreen(),//ImportDataScreen(),//ImportIncomeScreen(),
    );
  }
}

class MainNavigationScreen
    extends StatefulWidget {

  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen>
      createState() =>
          _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<
        MainNavigationScreen> {

  int selectedIndex = 0;

  final List<Widget> screens = [

    const DashboardScreen(),

    const TransactionsScreen(),
  ];

  Future<void> onTabTapped(
    int index,
  ) async {

    // ADD TRANSACTION
    if (index == 1) {

      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const AddTransactionScreen(),
        ),
      );

      return;
    }

    setState(() {

      selectedIndex =
          index > 1
              ? index - 1
              : index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: const AppDrawer(),

      body: screens[selectedIndex],

 bottomNavigationBar: Container(

  margin: const EdgeInsets.only(
    left: 16,
    right: 16,
    bottom: 16,
  ),

  decoration: BoxDecoration(

    color: Colors.white,

    borderRadius:
        BorderRadius.circular(30),

    boxShadow: [

      BoxShadow(

        color:
            Colors.black.withOpacity(
          0.05,
        ),

        blurRadius: 10,

        offset: const Offset(0, 4),
      ),
    ],
  ),

  child: ClipRRect(

    borderRadius:
        BorderRadius.circular(30),

    child: BottomNavigationBar(

      currentIndex:
          selectedIndex == 0
              ? 0
              : 2,

      onTap: onTabTapped,

      backgroundColor:
          Colors.white,

      elevation: 0,

      type:
          BottomNavigationBarType.fixed,

      selectedItemColor:
          Colors.green,

      unselectedItemColor:
          Colors.grey,

      selectedFontSize: 12,

      unselectedFontSize: 12,

      items: const [

        BottomNavigationBarItem(

          icon: Padding(

            padding:
                EdgeInsets.only(top: 6),

            child: Icon(Icons.home),
          ),

          label: 'Home',
        ),

        BottomNavigationBarItem(

          icon: Padding(

            padding:
                EdgeInsets.only(top: 6),

            child: Icon(
              Icons.add_circle,
              size: 34,
            ),
          ),

          label: 'Add',
        ),

        BottomNavigationBarItem(

          icon: Padding(

            padding:
                EdgeInsets.only(top: 6),

            child: Icon(
              Icons.receipt_long,
            ),
          ),

          label: 'Transactions',
        ),
      ],
    ),
  ),
),
    );
  }
}

class AppDrawer
    extends StatelessWidget {

  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Drawer(

      backgroundColor:
          const Color(0xFFF5F6FA),

      child: SafeArea(

        child: Column(

          children: [

            // TOP HEADER
            Container(

              width: double.infinity,

              margin:
                  const EdgeInsets.all(
                16,
              ),

              padding:
                  const EdgeInsets.all(
                22,
              ),

              decoration: BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [
                    Color(0xFF1DBF73),
                    Color(0xFF17A866),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),

              child: const Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  CircleAvatar(

                    radius: 28,

                    backgroundColor:
                        Colors.white,

                    child: Icon(

                      Icons.wallet,

                      color:
                          Colors.green,

                      size: 30,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(

                    'Money Tracker',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(

                    'Track every rupee smartly',

                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(

              child: ListView(

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                ),

                children: [

                  drawerSectionTitle(
                    'SETUP',
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.money_off,

                    title:
                        'Expense Categories',

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              GenericSetupScreen(

                            title:
                                'Expense Categories',

                            collection:
                                FirestoreCollections
                                    .expenseCategories,

                            hasDetails:
                                true,
                          ),
                        ),
                      );
                    },
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.savings,

                    title:
                        'Income Categories',

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              GenericSetupScreen(

                            title:
                                'Income Categories',

                            collection:
                                FirestoreCollections
                                    .incomeCategories,

                            hasDetails:
                                true,
                          ),
                        ),
                      );
                    },
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.compare_arrows,

                    title:
                        'Transfer Categories',

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              GenericSetupScreen(

                            title:
                                'Transfer Categories',

                            collection:
                                FirestoreCollections
                                    .transferCategories,

                            hasDetails:
                                true,
                          ),
                        ),
                      );
                    },
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.credit_card,

                    title:
                        'Payment Methods',

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

                  drawerTile(

                    context,

                    icon:
                        Icons.people_alt_outlined,

                    title:
                        'Persons',

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              GenericSetupScreen(

                            title:
                                'Persons',

                            collection:
                                FirestoreCollections
                                    .persons,
                          ),
                        ),
                      );
                    },
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.sell_outlined,

                    title:
                        'Tags',

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              GenericSetupScreen(

                            title:
                                'Tags',

                            collection:
                                FirestoreCollections
                                    .tags,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  drawerSectionTitle(
                    'MORE',
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.settings_outlined,

                    title:
                        'Settings',

                    onTap: () {},
                  ),

                  drawerTile(

                    context,

                    icon:
                        Icons.backup_outlined,

                    title:
                        'Backup & Export',

                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerSectionTitle(
    String title,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        left: 14,
        bottom: 10,
        top: 10,
      ),

      child: Text(

        title,

        style: TextStyle(

          color: Colors.grey.shade600,

          fontWeight:
              FontWeight.bold,

          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget drawerTile(

    BuildContext context, {

    required IconData icon,

    required String title,

    required VoidCallback onTap,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: ListTile(

        leading: Icon(
          icon,
          color: Colors.green,
        ),

        title: Text(
          title,
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }
}
