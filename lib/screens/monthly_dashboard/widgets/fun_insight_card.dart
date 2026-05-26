import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class FunInsightCard extends StatelessWidget {
  final String insight;

  final bool isHealthy;

  const FunInsightCard({
    super.key,

    required this.insight,

    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final bool danger = !isHealthy;

    final Color primaryColor = danger
        ? const Color(0xFFFF7043)
        : const Color(0xFF00C853);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: danger
              ? [const Color(0xFFFFF3F0), const Color(0xFFFFF8F3)]
              : [const Color(0xFFEAFBF1), const Color(0xFFF3FFF7)],
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: primaryColor.withOpacity(0.10)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),

            blurRadius: 12,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================
          // EMOJI
          // =====================
          Container(
            height: 50,

            width: 50,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Center(
              child: Text(getEmoji(), style: const TextStyle(fontSize: 26)),
            ),
          ),

          const SizedBox(width: 14),

          // =====================
          // CONTENT
          // =====================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fun Insight',

                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        getTag(),

                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryColor,

                          fontWeight: FontWeight.bold,

                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  insight,

                  maxLines: 3,

                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.4,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // DYNAMIC TAG
  // =====================

  String getTag() {
    if (insight.contains('Swiggy')) {
      return 'FOOD ARC';
    }

    if (insight.contains('Zara')) {
      return 'LIFESTYLE';
    }

    if (insight.contains('OTT')) {
      return 'ENTERTAINMENT';
    }

    if (insight.contains('UPI')) {
      return 'SPENDING CHAOS';
    }

    if (insight.contains('Vacation')) {
      return 'TRAVEL MODE';
    }

    if (insight.contains('Mirror')) {
      return 'SELF CARE';
    }

    if (dangerTag()) {
      return 'OVERSPENDING';
    }

    return 'MONTHLY VIBE';
  }

  // =====================
  // DYNAMIC EMOJI
  // =====================

  String getEmoji() {
    if (insight.contains('Swiggy')) {
      return '🍔';
    }

    if (insight.contains('Zara')) {
      return '🛍';
    }

    if (insight.contains('OTT')) {
      return '📺';
    }

    if (insight.contains('UPI')) {
      return '💸';
    }

    if (insight.contains('Vacation')) {
      return '✈️';
    }

    if (insight.contains('Mirror')) {
      return '🪞';
    }

    return isHealthy ? '😎' : '😭';
  }

  bool dangerTag() {
    return insight.contains('Disaster') ||
        insight.contains('Destroyed') ||
        insight.contains('Poor') ||
        insight.contains('Collapsed');
  }
}
