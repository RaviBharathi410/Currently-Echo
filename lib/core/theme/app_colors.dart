import 'package:flutter/material.dart';

/// Single source of truth for ECHO design tokens.
/// Strictly monochromatic light-blue and white palette.
/// Zero red, green, yellow, orange, or pink are permitted anywhere in the app.
abstract class AppColors {
  // Base
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface = Color(0xFFF4F8FC);
  static const Color surfaceSubtle = Color(0xFFEAF2FA);

  // Tonal Blue Steps
  static const Color blue100 = Color(0xFFE1EEFA); // Inactive pill, subtle fill
  static const Color blue200 = Color(0xFFB9D8F4); // Dividers, subtle decorative lines
  static const Color blue300 = Color(0xFF7AB4EA); // Decorative accents (non-interactive)
  static const Color blue400 = Color(0xFF3B8ED8); // Active pills, functional borders, switch tracks (3.48:1 contrast)
  static const Color blue500 = Color(0xFF1967B3); // Primary CTA fill, active icons, focus ring, error (4.92:1 on blue100, 5.80:1 on white)

  // Text & Icons (Contrast verified against surface & white)
  // 15.93:1 against white; 14.96:1 against surface (WCAG AAA)
  static const Color textPrimary = Color(0xFF0D233A);
  // 5.58:1 against white; 5.24:1 against surface (WCAG AA)
  static const Color textSecondary = Color(0xFF4A6B8A);
  // Disabled state only (Exempt per WCAG 1.4.3)
  static const Color textDisabled = Color(0xFF8CA5BD);

  // Borders & Functional Outlines
  static const Color border = Color(0xFFD0E1F0);
  static const Color borderFunctional = Color(0xFF3B8ED8); // Meets WCAG 1.4.11 >= 3:1
  static const Color borderFocused = Color(0xFF1967B3);
  static const Color focusRing = Color(0xFF1967B3);

  // Pressed/Tonal interaction overlays
  static const Color splashOverlay = Color(0x1A1967B3);
  static const Color highlightOverlay = Color(0x0D1967B3);

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Soft Tint Backdrop Tokens (Monochromatic alpha steps on AppColors.surface)
  // Radial tint A: ~45% alpha of blue100 (0x73 / 0xFF = 45.1%)
  static const Color backdropTintA = Color(0x73E1EEFA);
  // Radial tint B: ~35% alpha of blue100 (0x59 / 0xFF = 34.9%)
  static const Color backdropTintB = Color(0x59E1EEFA);
  // Radial tint Center: ~25% alpha of blue100 (0x40 / 0xFF = 25.1%)
  static const Color backdropTintCenter = Color(0x40E1EEFA);
  // Zero-alpha blue100 fade endpoint for gradient interpolation without black artifacts
  static const Color backdropFade = Color(0x00E1EEFA);
  // Ambient acoustic wave: ~10% alpha of blue200 (0x1A / 0xFF = 10.2%)
  static const Color backdropWave = Color(0x1AB9D8F4);

  // Split Horizon Echo Ghost Tokens (Acoustic echoes expanding across split line)
  // Top half ghosts (against blue500 surface): opacities 0.45 (0x73), 0.28 (0x47), 0.14 (0x24)
  static const Color splashGhostTop1 = Color(0x737AB4EA); // 45% alpha of blue300
  static const Color splashGhostTop2 = Color(0x47B9D8F4); // 28% alpha of blue200
  static const Color splashGhostTop3 = Color(0x24B9D8F4); // 14% alpha of blue200
  // Bottom half ghosts (against white surface): opacities 0.45 (0x73), 0.28 (0x47), 0.14 (0x24)
  static const Color splashGhostBottom1 = Color(0x73B9D8F4); // 45% alpha of blue200
  static const Color splashGhostBottom2 = Color(0x47E1EEFA); // 28% alpha of blue100
  static const Color splashGhostBottom3 = Color(0x24E1EEFA); // 14% alpha of blue100
}
