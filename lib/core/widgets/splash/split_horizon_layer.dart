import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'echo_wordmark.dart';

/// Renders the Split Horizon animation layer:
/// 1. Top half blue500 sliding down to 50% height with subtle blue400 horizon gradient, retracting vertically upward at exit
/// 2. 2dp split line drawing outward from center or filling left-to-right as readiness advances
/// 3. Dual-clipped ECHO wordmark (white on top, blue500 on bottom)
/// 4. 3 acoustic ghost echoes expanding upward & downward (opacities 0.45, 0.28, 0.14)
/// 5. Tagline "Your ideas, amplified." fading in below the split line in blue500
class SplitHorizonLayer extends StatelessWidget {
  final double animationValue; // 0.0 to 1.0 (representing 0.0s to 2.6s)
  final double readinessProgress; // 0.0 to 1.0
  final bool isReduceMotion;
  final bool showProgressText;

  const SplitHorizonLayer({
    super.key,
    required this.animationValue,
    this.readinessProgress = 0.0,
    this.isReduceMotion = false,
    this.showProgressText = false,
  });

  static const double _boxWidth = 320.0;
  static const double _boxHeight = 160.0;
  static const double _boxSplitY = _boxHeight / 2.0; // 80.0

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final splitY = height * 0.5;

          if (isReduceMotion) {
            return _buildStaticFrame(width, height, splitY);
          }

          return _buildAnimatedSequence(width, height, splitY);
        },
      ),
    );
  }

  Widget _buildStaticFrame(double width, double height, double splitY) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bottom half: subtle gradient fade from surfaceSubtle into pure white
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surfaceSubtle,
                AppColors.white,
              ],
              stops: [0.0, 0.25],
            ),
          ),
        ),

        // Top half: blue500 fading softly towards blue400 at the horizon
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: splitY,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blue500,
                  AppColors.blue500,
                  AppColors.blue400,
                ],
                stops: [0.0, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // Split line: full width 2dp blue400
        Positioned(
          top: splitY - 1.0,
          left: 0,
          right: 0,
          height: 2.0,
          child: const ColoredBox(color: AppColors.blue400),
        ),

        // Centered dual-clipped wordmark (white on top, blue500 on bottom)
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: _boxWidth,
              height: _boxHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Top clipped copy: white on blue500
                  ClipRect(
                    clipper: const _HalfClipper(isTop: true, splitY: _boxSplitY),
                    child: const SizedBox(
                      width: _boxWidth,
                      height: _boxHeight,
                      child: Center(
                        child: EchoWordmark(color: AppColors.white),
                      ),
                    ),
                  ),
                  // Bottom clipped copy: blue500 on white
                  ClipRect(
                    clipper: const _HalfClipper(isTop: false, splitY: _boxSplitY),
                    child: const SizedBox(
                      width: _boxWidth,
                      height: _boxHeight,
                      child: Center(
                        child: EchoWordmark(color: AppColors.blue500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tagline below split line ("Your ideas, amplified." in blue500)
        Positioned(
          top: splitY + AppSpacing.p40,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Your ideas, amplified.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: AppColors.blue500,
                letterSpacing: 0.0,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSequence(double width, double height, double splitY) {
    final t = animationValue.clamp(0.0, 1.0);

    // -------------------------------------------------------------------------
    // Phase 1: 0.0s - 0.6s (Interval [0.0, 0.2308]): Slide down & line draw
    // -------------------------------------------------------------------------
    final tSlideDown = _interval(t, 0.0, 0.2308, Curves.easeOutCubic);
    // Phase 4: 2.2s - 2.6s (Interval [0.8462, 1.0]): Retract upward
    final tRetract = _interval(t, 0.8462, 1.0, Curves.easeInOutCubic);

    final topHalfHeight = splitY * tSlideDown;
    final topHalfOffset = -splitY * tRetract;

    // Split line width expansion:
    // When readinessProgress > 0: line fills from left to right per real readiness progress
    // When readinessProgress == 0: line draws outward from center during Phase 1
    final isLeftToRight = readinessProgress > 0.0;
    final tLineDraw = _interval(t, 0.0, 0.2308, Curves.easeOutCubic);
    final effectiveProgress = isLeftToRight
        ? readinessProgress.clamp(0.0, 1.0)
        : math.max(tLineDraw, readinessProgress.clamp(0.0, 1.0));
    final lineWidth = width * effectiveProgress;
    final lineLeft = isLeftToRight ? 0.0 : (width - lineWidth) / 2.0;

    // White half exit fade
    final whiteHalfOpacity = 1.0 - _interval(t, 0.8462, 1.0, Curves.easeOut);

    // -------------------------------------------------------------------------
    // Phase 2: 0.5s - 1.2s (Interval [0.1923, 0.4615]): Staggered letter reveal
    // -------------------------------------------------------------------------
    final pE = _interval(t, 0.1923, 0.3077, Curves.easeOutCubic);
    final pC = _interval(t, 0.2154, 0.3308, Curves.easeOutCubic);
    final pH = _interval(t, 0.2385, 0.3538, Curves.easeOutCubic);
    final pO = _interval(t, 0.2615, 0.3769, Curves.easeOutCubic);

    // Global wordmark fade out at exit (2.2s - 2.5s)
    final wordmarkGlobalOpacity = 1.0 - _interval(t, 0.8462, 0.9615, Curves.easeOut);

    // -------------------------------------------------------------------------
    // Phase 3: 1.2s - 2.0s (Interval [0.4615, 0.7692]): Acoustic ghost echoes
    // -------------------------------------------------------------------------
    final tEcho = _interval(t, 0.4615, 0.7692, Curves.easeOutCubic);
    // Ghosts fade out towards the end of Phase 3
    final echoFade = 1.0 - _interval(t, 0.6538, 0.7692, Curves.easeOut);

    // -------------------------------------------------------------------------
    // Phase 4: 2.0s - 2.6s (Interval [0.7692, 1.0]): Tagline fade in
    // -------------------------------------------------------------------------
    final taglineOpacity = _interval(t, 0.7692, 0.8846, Curves.easeOut) * (1.0 - tRetract);

    // Live progress percentage text display (bottom row behavior)
    final displayPercent = (effectiveProgress * 100).toInt().clamp(0, 100);
    final bool showPercentUnderLine = (isLeftToRight && readinessProgress < 1.0) || showProgressText;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base white surface with soft gradient fade towards the horizon
        Opacity(
          opacity: whiteHalfOpacity.clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceSubtle,
                  AppColors.white,
                ],
                stops: [0.0, 0.25],
              ),
            ),
          ),
        ),

        // Top blue half (slides down from 0 to 50%, then retracts upward off-screen)
        // Includes a subtle gradient fade to blue400 at the lower edge
        Positioned(
          top: topHalfOffset,
          left: 0,
          right: 0,
          height: topHalfHeight.clamp(0.0, height),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blue500,
                  AppColors.blue500,
                  AppColors.blue400,
                ],
                stops: [0.0, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // Split line: 2dp centered on splitY
        Positioned(
          top: splitY - 1.0,
          left: lineLeft,
          width: lineWidth,
          height: 2.0,
          child: Opacity(
            opacity: whiteHalfOpacity.clamp(0.0, 1.0),
            child: const ColoredBox(color: AppColors.blue400),
          ),
        ),

        // Wordmark and Acoustic Ghost Trails
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: _boxWidth,
              height: _boxHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Acoustic Ghost Echoes (Phase 3: expanding outward)
                  if (tEcho > 0.0 && echoFade > 0.0) ...[
                    // Ghost 3 (Furthest, scale 1.24, 48dp travel)
                    _buildGhostPair(
                      splitY: _boxSplitY,
                      verticalOffset: 48.0 * tEcho,
                      scale: 1.0 + (0.24 * tEcho),
                      topColor: AppColors.splashGhostTop3,
                      bottomColor: AppColors.splashGhostBottom3,
                      opacity: echoFade,
                    ),
                    // Ghost 2 (Mid, scale 1.16, 32dp travel)
                    _buildGhostPair(
                      splitY: _boxSplitY,
                      verticalOffset: 32.0 * tEcho,
                      scale: 1.0 + (0.16 * tEcho),
                      topColor: AppColors.splashGhostTop2,
                      bottomColor: AppColors.splashGhostBottom2,
                      opacity: echoFade,
                    ),
                    // Ghost 1 (Closest, scale 1.08, 16dp travel)
                    _buildGhostPair(
                      splitY: _boxSplitY,
                      verticalOffset: 16.0 * tEcho,
                      scale: 1.0 + (0.08 * tEcho),
                      topColor: AppColors.splashGhostTop1,
                      bottomColor: AppColors.splashGhostBottom1,
                      opacity: echoFade,
                    ),
                  ],

                  // 2. Primary Dual-Clipped Wordmark
                  // Top copy: white on blue500, clipped to top half (y <= 80)
                  ClipRect(
                    clipper: const _HalfClipper(isTop: true, splitY: _boxSplitY),
                    child: SizedBox(
                      width: _boxWidth,
                      height: _boxHeight,
                      child: Center(
                        child: EchoWordmark(
                          color: AppColors.white,
                          letterProgressE: pE,
                          letterProgressC: pC,
                          letterProgressH: pH,
                          letterProgressO: pO,
                          globalOpacity: wordmarkGlobalOpacity,
                        ),
                      ),
                    ),
                  ),

                  // Bottom copy: blue500 on white, clipped to bottom half (y >= 80)
                  ClipRect(
                    clipper: const _HalfClipper(isTop: false, splitY: _boxSplitY),
                    child: SizedBox(
                      width: _boxWidth,
                      height: _boxHeight,
                      child: Center(
                        child: EchoWordmark(
                          color: AppColors.blue500,
                          letterProgressE: pE,
                          letterProgressC: pC,
                          letterProgressH: pH,
                          letterProgressO: pO,
                          globalOpacity: wordmarkGlobalOpacity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Progress percentage text below the line during loading (bottom row behavior)
        if (showPercentUnderLine)
          Positioned(
            top: splitY + AppSpacing.p16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '$displayPercent%',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue500,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),

        // Tagline below the line ("Your ideas, amplified." in blue500)
        if (taglineOpacity > 0.0 && !showPercentUnderLine)
          Positioned(
            top: splitY + AppSpacing.p40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: taglineOpacity.clamp(0.0, 1.0),
              child: const Center(
                child: Text(
                  'Your ideas, amplified.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue500,
                    letterSpacing: 0.0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGhostPair({
    required double splitY,
    required double verticalOffset,
    required double scale,
    required Color topColor,
    required Color bottomColor,
    required double opacity,
  }) {
    return ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top ghost: expands UP into blue half
          ClipRect(
            clipper: _HalfClipper(isTop: true, splitY: splitY),
            child: SizedBox(
              width: _boxWidth,
              height: _boxHeight,
              child: Center(
                child: EchoWordmark(
                  color: topColor,
                  verticalOffset: -verticalOffset,
                  scale: scale,
                  globalOpacity: opacity,
                ),
              ),
            ),
          ),
          // Bottom ghost: expands DOWN into white half
          ClipRect(
            clipper: _HalfClipper(isTop: false, splitY: splitY),
            child: SizedBox(
              width: _boxWidth,
              height: _boxHeight,
              child: Center(
                child: EchoWordmark(
                  color: bottomColor,
                  verticalOffset: verticalOffset,
                  scale: scale,
                  globalOpacity: opacity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _interval(double value, double begin, double end, Curve curve) {
    if (value <= begin) return 0.0;
    if (value >= end) return 1.0;
    final normalized = (value - begin) / (end - begin);
    return curve.transform(normalized.clamp(0.0, 1.0));
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool isTop;
  final double splitY;

  const _HalfClipper({required this.isTop, required this.splitY});

  @override
  Rect getClip(Size size) {
    if (isTop) {
      return Rect.fromLTRB(-200.0, -200.0, size.width + 200.0, splitY);
    } else {
      return Rect.fromLTRB(-200.0, splitY, size.width + 200.0, size.height + 200.0);
    }
  }

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) {
    return oldClipper.isTop != isTop || oldClipper.splitY != splitY;
  }
}
