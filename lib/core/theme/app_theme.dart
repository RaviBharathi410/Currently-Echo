import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radii.dart';

abstract class AppTheme {
  static ThemeData get light {
    final textTheme = AppTypography.createTextTheme();

    // Strictly monochromatic light-blue and white ColorScheme.
    // ColorScheme.error is explicitly set to AppColors.blue500 to override Flutter's default red.
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.blue500,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.blue100,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.blue400,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.blue100,
      onSecondaryContainer: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceSubtle,
      error: AppColors.blue500,
      onError: AppColors.white,
      outline: AppColors.borderFunctional,
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.transparent,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashColor: AppColors.splashOverlay,
      highlightColor: AppColors.highlightOverlay,
      focusColor: AppColors.blue100,
      hoverColor: AppColors.surfaceSubtle,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.roundedLg,
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.roundedLg,
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        modalBackgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue500;
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue100;
          return AppColors.surfaceSubtle;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue400;
          return AppColors.blue400;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
