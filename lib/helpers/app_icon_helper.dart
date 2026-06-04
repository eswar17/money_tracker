import 'package:flutter/material.dart';

class AppIconHelper {
  AppIconHelper._();

  static const IconData defaultIcon = Icons.category_rounded;

  static const Map<String, IconData> iconMap = {
    // Transaction Types
    'Income': Icons.arrow_downward_rounded,
    'Expense': Icons.arrow_upward_rounded,
    'Transfer': Icons.swap_horiz_rounded,
    'Bank Move': Icons.swap_horiz_rounded,

    // Main Categories
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Health': Icons.local_hospital_rounded,
    'Household': Icons.home_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Lifestyle': Icons.checkroom_rounded,
    'Entertainment': Icons.movie_rounded,
    'Subscriptions': Icons.subscriptions_rounded,
    'Savings': Icons.account_balance_rounded,
    'Charity': Icons.volunteer_activism_rounded,
    'Trips': Icons.flight_rounded,
    'Others': Icons.category_rounded,
    'Loans': Icons.credit_card_rounded,
    'Insurance': Icons.shield_rounded,
    'Salary': Icons.work_rounded,
    'Profit': Icons.trending_up_rounded,
    'Rewards': Icons.emoji_events_rounded,
    'Gift': Icons.card_giftcard_rounded,
    'Gifts': Icons.card_giftcard_rounded,

    // Food Details
    'Junk Food': Icons.fastfood_rounded,
    'Dining': Icons.restaurant_menu_rounded,
    'Groceries': Icons.shopping_cart_rounded,
    'Food Order': Icons.delivery_dining_rounded,
    //'Fruits': Icons.apple_rounded,
    'Fruits': Icons.eco_rounded,
    'Vegetables': Icons.eco_rounded,
    'Meat': Icons.set_meal_rounded,
    'Coconut Water': Icons.local_drink_rounded,
    'Juices': Icons.local_bar_rounded,
    'Dairy': Icons.breakfast_dining_rounded,

    // Transport Details
    'Fuel': Icons.local_gas_station_rounded,
    'Cab': Icons.local_taxi_rounded,
    'Bus': Icons.directions_bus_rounded,
    'Train': Icons.train_rounded,
    'Plane': Icons.flight_rounded,
    'Vehicle Maintenance': Icons.build_rounded,
    'Metro': Icons.subway_rounded,
    'Parking/Tolls': Icons.local_parking_rounded,

    // Health Details
    'Medicine': Icons.medication_rounded,
    'Hospital': Icons.local_hospital_rounded,
    'Treatment': Icons.healing_rounded,
    'Supplements': Icons.fitness_center_rounded,
    'Tests / Scans': Icons.science_rounded,

    // Household Details
    'Rent': Icons.home_rounded,
    'House rent': Icons.home_rounded,
    'Hygiene': Icons.clean_hands_rounded,
    'Essentials': Icons.shopping_basket_rounded,
    'Maintenance': Icons.handyman_rounded,

    // Bills Details
    'Electricity': Icons.bolt_rounded,
    'Water': Icons.water_drop_rounded,
    'Gas': Icons.local_fire_department_rounded,
    'Internet': Icons.wifi_rounded,
    'Mobile Recharge': Icons.smartphone_rounded,
    'Credit Card Bill': Icons.credit_card_rounded,
    'CC Bills Before April 2026': Icons.credit_card_rounded,

    // Lifestyle Details
    'Clothes': Icons.checkroom_rounded,
    'Shoes': Icons.hiking_rounded,
    'Grooming': Icons.content_cut_rounded,
    'Accessories': Icons.watch_rounded,

    // Entertainment Details
    'Movies': Icons.movie_rounded,
    'Games': Icons.sports_esports_rounded,
    'OTT': Icons.tv_rounded,
    'Apps': Icons.apps_rounded,

    // Savings Details
    'SIP': Icons.show_chart_rounded,
    'Mutual Funds': Icons.analytics_rounded,
    //'Stocks': Icons.candlestick_chart_rounded,
    'Stocks': Icons.show_chart_rounded,
    'Crypto': Icons.currency_bitcoin_rounded,
    'FD': Icons.account_balance_wallet_rounded,
    'PPF': Icons.savings_rounded,
    'Post Office': Icons.local_post_office_rounded,
    'Chitti': Icons.menu_book_rounded,
    'RD': Icons.payments_rounded,

    // Charity Details
    'Temple': Icons.temple_hindu_rounded,
    //'NGO': Icons.handshake_rounded,
    'NGO': Icons.volunteer_activism_rounded,
    'Donations': Icons.favorite_rounded,

    // Trip Details
    'Hotel': Icons.hotel_rounded,
    'SPA': Icons.spa_rounded,
    'Photo': Icons.photo_camera_rounded,
    'Memories': Icons.photo_library_rounded,
    'Shopping': Icons.shopping_bag_rounded,

    // Loans & Insurance
    'EMI': Icons.event_note_rounded,
    'Term': Icons.shield_rounded,

    // People
    'Bhavya': Icons.person_rounded,
    'Annayya': Icons.person_rounded,
    'Pavan': Icons.person_rounded,
    'Latha': Icons.person_rounded,
    'Eswar': Icons.person_rounded,
    'Both': Icons.groups_rounded,
    'Parents': Icons.groups_rounded,
    'Latha Family': Icons.family_restroom_rounded,
    'Eswar Family': Icons.family_restroom_rounded,

    // Income Sources
    'TechM': Icons.business_center_rounded,
    'Idea Elan': Icons.lightbulb_rounded,
    'Opening Balance': Icons.account_balance_wallet_rounded,
    'Scratch Cards': Icons.confirmation_number_rounded,
    'Cashback': Icons.redeem_rounded,

    // Accounts
    'Cash': Icons.payments_rounded,
    'Sodexo': Icons.lunch_dining_rounded,
    'Meal Card': Icons.lunch_dining_rounded,
    'Cred': Icons.account_balance_wallet_rounded,
    'Cred Flash': Icons.flash_on_rounded,
    'Cred Rewards': Icons.emoji_events_rounded,
    'Credit Card': Icons.credit_card_rounded,
    'Debit Card': Icons.credit_score_rounded,
    'Axis Flipkart': Icons.credit_card_rounded,
    'Axis Rupay': Icons.credit_card_rounded,
    'HDFC Credit': Icons.credit_card_rounded,
    'RBL': Icons.credit_card_rounded,
    'Latha Credit': Icons.credit_card_rounded,
    'HDFC Debit': Icons.credit_score_rounded,
    'UCO Debit': Icons.credit_score_rounded,
    'Latha Debit': Icons.credit_score_rounded,
    'Cash Withdraw': Icons.atm_rounded,

    // Misc
    'Miscellaneous': Icons.category_rounded,
  };

  static IconData getIcon(String? value) {
    if (value == null || value.trim().isEmpty) {
      return defaultIcon;
    }

    return iconMap[value.trim()] ?? defaultIcon;
  }
}
