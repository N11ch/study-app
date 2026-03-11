import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Central place for named text styles used in the app.
///
/// These are thin aliases around the base Material [TextTheme]
/// so you can refer to them semantically in UI code.
class AppTypography {
  AppTypography._();

  static TextStyle headline(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall ??
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle link(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ) ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );
}
