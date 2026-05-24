import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {

  static const TextStyle heading2 =
    TextStyle(

  fontSize: 22,

  fontWeight: FontWeight.bold,

  color: Colors.black,
);

static const TextStyle heading3 =
    TextStyle(

  fontSize: 18,

  fontWeight: FontWeight.w700,

  color: Colors.black,
);

static const TextStyle bodyLarge =
    TextStyle(

  fontSize: 16,

  color: Colors.black87,
);

static const TextStyle bodyMedium =
    TextStyle(

  fontSize: 14,

  color: Colors.black87,
);

static const TextStyle bodySmall =
    TextStyle(

  fontSize: 12,

  color: Colors.black54,
);

static const TextStyle heading1 =
    TextStyle(

  fontSize: 32,

  fontWeight: FontWeight.bold,

  color: Colors.black,
);

  static const TextStyle heading =
      TextStyle(

    fontSize: 26,

    fontWeight: FontWeight.bold,

    color:
        AppColors.textPrimary,
  );

  static const TextStyle title =
      TextStyle(

    fontSize: 18,

    fontWeight: FontWeight.w600,

    color:
        AppColors.textPrimary,
  );

  static const TextStyle body =
      TextStyle(

    fontSize: 15,

    color:
        AppColors.textSecondary,
  );

  static const TextStyle button =
      TextStyle(

    fontSize: 16,

    fontWeight: FontWeight.w600,

    color: Colors.white,
  );
}