import 'package:flutter/material.dart';

/// Single source of truth for ECHO design tokens.
/// Strictly monochromatic light-blue and white palette.
/// Modern Electric Royal Blue spectrum matching the signature brand reference.
abstract class AppColors {
  // Base
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface = Color(0xFFF6F9FD);
  static const Color surfaceSubtle = Color(0xFFEDF3FB);

  // Tonal Blue Steps
  static const Color blue100 = Color(0xFFE8F1FF); // Inactive pill, subtle fill
  static const Color blue200 = Color(0xFFB8D5FF); // Dividers, subtle decorative lines
  static const Color blue300 = Color(0xFF70A9FF); // Decorative accents (non-interactive)
  static const Color blue400 = Color(0xFF2E82F7); // Active pills, functional borders, switch tracks (3.72:1 contrast)
  static const Color blue500 = Color(0xFF005CE6); // Primary CTA fill, active icons, focus ring, brand (5.02:1 on blue100, 5.72:1 on white)

  // Text & Icons (Contrast verified against surface & white)
  // 17.60:1 against white; 16.67:1 against surface (WCAG AAA)
  static const Color textPrimary = Color(0xFF0A192F);
  // 7.25:1 against white; 6.87:1 against surface (WCAG AA)
  static const Color textSecondary = Color(0xFF48586E);
  // Disabled state only (Exempt per WCAG 1.4.3)
  static const Color textDisabled = Color(0xFF8CA5BD);

  // Borders & Functional Outlines
  static const Color border = Color(0xFFDCE7F5);
  static const Color borderFunctional = Color(0xFF2E82F7); // Meets WCAG 1.4.11 >= 3:1
  static const Color borderFocused = Color(0xFF005CE6);
  static const Color focusRing = Color(0xFF005CE6);

  // Pressed/Tonal interaction overlays
  static const Color splashOverlay = Color(0x1A005CE6);
  static const Color highlightOverlay = Color(0x0D005CE6);

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Soft Tint Backdrop Tokens (Monochromatic alpha steps on AppColors.surface)
  // Radial tint A: ~45% alpha of blue100 (0x73 / 0xFF = 45.1%)
  static const Color backdropTintA = Color(0x73E8F1FF);
  // Radial tint B: ~35% alpha of blue100 (0x59 / 0xFF = 34.9%)
  static const Color backdropTintB = Color(0x59E8F1FF);
  // Radial tint Center: ~25% alpha of blue100 (0x40 / 0xFF = 25.1%)
  static const Color backdropTintCenter = Color(0x40E8F1FF);
  // Zero-alpha blue100 fade endpoint for gradient interpolation without black artifacts
  static const Color backdropFade = Color(0x00E8F1FF);
  // Ambient acoustic wave: ~10% alpha of blue200 (0x1A / 0xFF = 10.2%)
  static const Color backdropWave = Color(0x1AB8D5FF);

  // Split Horizon Echo Ghost Tokens (Acoustic echoes expanding across split line)
  // Top half ghosts (against blue500 surface): opacities 0.45 (0x73), 0.28 (0x47), 0.14 (0x24) in white
  static const Color splashGhostTop1 = Color(0x73FFFFFF); // 45% alpha white
  static const Color splashGhostTop2 = Color(0x47FFFFFF); // 28% alpha white
  static const Color splashGhostTop3 = Color(0x24FFFFFF); // 14% alpha white
  // Bottom half ghosts (against white surface): opacities 0.45 (0x73), 0.28 (0x47), 0.14 (0x24) in blue500
  static const Color splashGhostBottom1 = Color(0x73005CE6); // 45% alpha blue500
  static const Color splashGhostBottom2 = Color(0x47005CE6); // 28% alpha blue500
  static const Color splashGhostBottom3 = Color(0x24005CE6); // 14% alpha blue500
}
