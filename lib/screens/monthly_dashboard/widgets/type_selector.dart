import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class TypeSelector extends StatelessWidget {
  final String selectedType;

  final Function(String) onChanged;

  const TypeSelector({
    super.key,

    required this.selectedType,

    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'title': 'Expense', 'emoji': '💸'},

      {'title': 'Income', 'emoji': '💰'},

      {'title': 'Transfer', 'emoji': '🔄'},
    ];

    return Container(
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: types.map((typeData) {
          final String title = typeData['title']!;

          final String emoji = typeData['emoji']!;

          final bool selected = selectedType == title;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onChanged(title);
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),

                margin: const EdgeInsets.symmetric(horizontal: 4),

                padding: const EdgeInsets.symmetric(vertical: 14),

                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            title == 'Expense'
                                ? const Color(0xFFFF6B6B)
                                : title == 'Income'
                                ? const Color(0xFF00C853)
                                : const Color(0xFF2979FF),

                            title == 'Expense'
                                ? const Color(0xFFFF8E53)
                                : title == 'Income'
                                ? const Color(0xFF69F0AE)
                                : const Color(0xFF82B1FF),
                          ],
                        )
                      : null,

                  color: selected ? null : Colors.grey.shade100,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),

                    const SizedBox(height: 8),

                    Text(
                      title,

                      style: AppTextStyles.bodyMedium.copyWith(
                        color: selected ? Colors.white : Colors.black87,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
