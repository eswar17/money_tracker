import 'package:flutter/material.dart';

import '../../services/account_balance_service.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();

    future = AccountBalanceService().getAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(title: const Text('Accounts')),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snapshot.data!;

          if (accounts.isEmpty) {
            return const Center(child: Text('No Debit Accounts'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: accounts.length,

            itemBuilder: (_, index) {
              final account = accounts[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Container(
                      height: 52,

                      width: 52,

                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            account['title'],
                            style: const TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text('Available Balance'),
                        ],
                      ),
                    ),

                    Text(
                      '₹${(account['balance'] as double).toStringAsFixed(0)}',

                      style: const TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
