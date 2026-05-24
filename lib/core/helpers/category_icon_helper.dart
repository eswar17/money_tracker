import 'package:flutter/material.dart';

class CategoryIconHelper {
  static final Map<String, String> detailIcons = {
    // FOOD
    'junk food': '🍔',
    'dining': '🍽️',
    'groceries': '🛒',
    'food order': '🛵', //
    'fruits': '🍎',
    'vegetables': '🥦',
    'meat': '🍗',
    'coconut water': '🥥',
    'juices': '🧃',
    'dairy': '🥛',

    // TRANSPORT
    'fuel': '⛽',
    'cab': '🚕',
    'bus': '🚌',
    'train': '🚆',
    'plane': '✈️',
    'vehicle maintenance': '🚗',
    'metro': '🚇',
    'parking/tolls': '🅿️',

    // HEALTH
    'medicine': '💊',
    'hospital': '🏥',
    'treatment': '🩺',
    'supplements': '💪',
    'tests / scans': '🧪',

    // HOUSE
    'rent': '🏠',
    'maintenance': '🛠️',
    'electricity': '⚡',
    'water': '💧',
    'gas': '🔥',
    'internet': '🌐',

    // LIFESTYLE
    'clothes': '👕',
    'shoes': '👟',
    'grooming': '✂️',
    'accessories': '⌚',

    // ENTERTAINMENT
    'movies': '🎬',
    'games': '🎮',
    'ott': '📺',
    'apps': '📱',

    // SAVINGS
    'sip': '📈',
    'mutual funds': '📊',
    'stocks': '💹',
    'crypto': '₿',
    'fd': '🏦',
    'ppf': '💰',
    'rd': '💵',

    // CHARITY
    'temple': '🛕',
    'ngo': '🤝',
    'donations': '❤️',

    // TRIPS
    'gifts': '🎁',
    'transport': '🚘',
    'hotel': '🏨',
    'food': '🍜',
    'spa': '💆',
    'photo': '📸',
    'memories': '💞',
    'shopping': '🛍️',

    // LOANS
    'emi': '💳',
    'bhavya': '👩',
    'annayya': '👨',
    'pavan': '🧑',

    // INSURANCE
    'term': '🛡️',
    'health': '❤️‍🩹',

    // =====================
    // INCOME
    // =====================
    'techm': '💼',
    'idea elan': '💼',
    'sodexo': '🍱',

    'chitti': '💵',
    'opening balance': '🏦',

    'scratch cards': '🎰',
    'cashback': '💸',

    'latha family': '👨‍👩‍👧',
    'eswar family': '🏡',

    'house rent': '🏠',

    'miscellaneous': '✨',

    // =====================
    // TRANSFER
    // =====================
    'bank move': '🏦',

    'credit card': '💳',

    'cash withdraw': '💵',
  };

  static String getEmoji(String detail) {
    return detailIcons[detail.toLowerCase()] ?? '💰';
  }
}
