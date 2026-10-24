import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const String fontFamily = 'DMSans';

  /// Huge test frequency display (e.g. "1000 Hz", "2000 Hz") in screening test flow
  static const TextStyle frequencyDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 38.0,
    fontWeight: FontWeight.w700,
    height: 44.0 / 38.0,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Provisional logo size token outside the standard body scale (56sp Bold 700).
  /// Dedicated to the ECHO brand wordmark in launch splash and branded headers.
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56.0,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.0,
    decoration: TextDecoration.none,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 38.0 / 32.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 30.0 / 24.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 26.0 / 20.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 24.0 / 18.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 24.0 / 16.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 18.0 / 14.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 16.0 / 12.0,
    letterSpacing: 0.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 16.0 / 12.0,
    letterSpacing: 0.0,
    color: AppColors.textSecondary,
  );

  // ===========================================================================
  // Usage-Based Semantic Typography Tiers (ADR-010)
  // ===========================================================================

  /// Hero metric value display (e.g. "2h 15m", "45m", "Level 13")
  static const TextStyle statDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 34.0 / 28.0,
    letterSpacing: -0.5,
    color: AppColors.blue500,
  );

  /// Metric label below numbers (e.g. "Today's Listening", "Current Session")
  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 16.0 / 12.0,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  /// Primary card headers (e.g. "Daily Sound Exposure", "Tone Response Profile")
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    height: 24.0 / 18.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// Prominent section division headers (e.g. "Quick Access", "Screening Checklist")
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 26.0 / 20.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// Bold item titles (e.g. "Headphones Connected", form labels)
  static const TextStyle labelBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    height: 18.0 / 14.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// Emphasized bold body text
  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 20.0 / 14.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// Status badge & chip labels with bold weight
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 16.0 / 12.0,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static TextTheme createTextTheme() {
    return const TextTheme(
      displayLarge: displayLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: heading,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      bodySmall: caption,
    );
  }
}
