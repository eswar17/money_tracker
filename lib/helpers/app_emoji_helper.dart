// app_emoji_helper.dart

class AppEmojiHelper {
  AppEmojiHelper._();

  static const String defaultEmoji = '📦';

  static const Map<String, String> emojiMap = {
    // Transaction Types
    'Income': '💰',
    'Expense': '💸',
    'Transfer': '🔄',
    'Bank Move': '🏦',

    // Main Categories
    'Food': '🥗',
    'Transport': '🚗',
    'Health': '🏥',
    'Household': '🏠',
    'Bills': '📄',
    'Lifestyle': '👕',
    'Entertainment': '🎬',
    'Subscriptions': '📺',
    'Savings': '🏦',
    'Charity': '❤️',
    'Trips': '✈️',
    'Others': '📦',
    'Loans': '💳',
    'Insurance': '🛡️',
    'Salary': '👨‍💼',
    'Profit': '📈',
    'Rewards': '🏆',
    'Gift': '🎁',
    'Gifts': '🎁',
    'Family Support': '👨‍👩‍👧‍👦',
    'Investments': '🌱',

    // Food Details
    'Junk Food': '🍔',
    'Dining': '🍽️',
    'Groceries': '🛒',
    'Food Order': '🛵',
    'Fruits': '🍎',
    'Vegetables': '🥦',
    'Meat': '🍖',
    'Coconut Water': '🥥',
    'Juices': '🧃',
    'Dairy': '🥛',

    // Transport Details
    'Fuel': '⛽',
    'Cab': '🚕',
    'Bus': '🚌',
    'Train': '🚆',
    'Plane': '✈️',
    'Vehicle Maintenance': '🔧',
    'Metro': '🚇',
    'Parking/Tolls': '🅿️',

    // Health Details
    'Medicine': '💊',
    'Hospital': '🏥',
    'Treatment': '🩺',
    'Supplements': '💪',
    'Tests / Scans': '🧪',

    // Household Details
    'Rent': '🏠',
    'House rent': '🏠',
    'Hygiene': '🧼',
    'Essentials': '🛍️',
    'Maintenance': '🔨',
    'Home Furnishing': '🛋️',
    'Appliances': '🔌',

    // Bills Details
    'Electricity': '⚡',
    'Water': '💧',
    'Gas': '🔥',
    'Internet': '🌐',
    'Mobile Recharge': '📱',
    'Credit Card Bill': '💳',
    'CC Bills Before April 2026': '💳',

    // Lifestyle Details
    'Clothes': '👕',
    'Shoes': '👟',
    'Grooming': '✂️',
    'Accessories': '⌚',
    'Gym': '🏋️',

    // Entertainment Details
    'Movies': '🎬',
    'Games': '🎮',
    'OTT': '📺',
    'Apps': '📱',

    // Savings Details
    'SIP': '📊',
    'Mutual Funds': '📈',
    'Stocks': '📉',
    'Crypto': '₿',
    'FD': '🏦',
    'PPF': '💰',
    'Post Office': '📮',
    'Chitti': '📚',
    'RD': '💵',

    // Charity Details
    'Temple': '🛕',
    'NGO': '🤝',
    'Donations': '❤️',

    // Trip Details
    'Hotel': '🏨',
    'SPA': '💆',
    'Photo': '📸',
    'Memories': '🖼️',
    'Shopping': '🛍️',

    // Loans & Insurance
    'EMI': '📅',
    'Term': '🛡️',

    // People
    'Bhavya': '👩',
    'Amrutha': '👩',
    'Annayya': '👨',
    'Pavan': '👨',
    'Latha': '👩',
    'Eswar': '👨',
    'Both': '👨‍👩',
    'Parents': '👨‍👩',
    'Latha Family': '👨‍👩‍👧‍👦',
    'Eswar Family': '👨‍👩‍👧‍👦',

    // Income Sources
    'TechM': '💼',
    'Idea Elan': '💡',
    'Opening Balance': '💰',
    'Scratch Cards': '🎟️',
    'Cashback': '💸',

    // Accounts
    'Cash': '💵',
    'Sodexo': '🍱',
    'Meal Card': '🍱',
    'Cred': '💜',
    'Cred Flash': '⚡',
    'Cred Rewards': '🏆',
    'Credit Card': '💳',
    'Debit Card': '💳',
    'Axis Flipkart': '🛒',
    'Axis Rupay': '💳',
    'HDFC Credit': '💳',
    'RBL': '💳',
    'Latha Credit': '💳',
    'HDFC Debit': '💳',
    'UCO Debit': '💳',
    'Latha Debit': '💳',
    'Cash Withdraw': '🏧',

    // Misc
    'Miscellaneous': '📦',
  };

  static String getEmoji(String? value) {
    if (value == null || value.trim().isEmpty) {
      return defaultEmoji;
    }

    return emojiMap[value.trim()] ?? defaultEmoji;
  }
}
