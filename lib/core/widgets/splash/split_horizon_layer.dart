import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'echo_wordmark.dart';

/// Renders the Split Horizon animation layer:
/// 1. Top half blue500 sliding down to 50% height, retracting upward at exit
/// 2. 2dp split line drawing outward in blue400
/// 3. Dual-clipped ECHO wordmark (white on top, blue500 on bottom)
/// 4. 3 acoustic ghost echoes expanding upward & downward
/// 5. Tagline "Listen with awareness" fading in below the split line
class SplitHorizonLayer extends StatelessWidget {
  final double animationValue; // 0.0 to 1.0 (representing 0.0s to 2.6s)
  final double readinessProgress; // 0.0 to 1.0
  final bool isReduceMotion;

  const SplitHorizonLayer({
    super.key,
    required this.animationValue,
    this.readinessProgress = 0.0,
    this.isReduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final splitY = height * 0.5;

        if (isReduceMotion) {
          return _buildStaticFrame(width, height, splitY);
        }

        return _buildAnimatedSequence(width, height, splitY);
      },
    );
  }

  Widget _buildStaticFrame(double width, double height, double splitY) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bottom half: pure white
        const ColoredBox(color: AppColors.white),

        // Top half: blue500 to exactly 50% height
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: splitY,
          child: const ColoredBox(color: AppColors.blue500),
        ),

        // Split line: full width 2dp blue400
        Positioned(
          top: splitY - 1.0,
          left: 0,
          right: 0,
          height: 2.0,
          child: const ColoredBox(color: AppColors.blue400),
        ),

        // Centered dual-clipped wordmark
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 320.0,
              height: 180.0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Top clipped copy: white on blue500
                  ClipRect(
                    clipper: _HalfClipper(isTop: true, splitY: 90.0),
                    child: const EchoWordmark(color: AppColors.white),
                  ),
                  // Bottom clipped copy: blue500 on white
                  ClipRect(
                    clipper: _HalfClipper(isTop: false, splitY: 90.0),
                    child: const EchoWordmark(color: AppColors.blue500),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tagline below split line
        Positioned(
          top: splitY + AppSpacing.p40,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Listen with awareness',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                letterSpacing: 0.0,
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

    final topHalfHeight = splitY * tSlideDown * (1.0 - tRetract);

    // Split line width expansion from center
    final tLineDraw = _interval(t, 0.0, 0.2308, Curves.easeOutCubic);
    final effectiveLineWidthFactor = math.max(tLineDraw, readinessProgress.clamp(0.0, 1.0));
    final lineWidth = width * effectiveLineWidthFactor;

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

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base white surface (fades out at exit reveal)
        Opacity(
          opacity: whiteHalfOpacity.clamp(0.0, 1.0),
          child: const ColoredBox(color: AppColors.white),
        ),

        // Top blue half (slides down from 0 to 50%, then retracts to 0)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topHalfHeight.clamp(0.0, height),
          child: const ColoredBox(color: AppColors.blue500),
        ),

        // Split line: 2dp centered on splitY
        Positioned(
          top: splitY - 1.0,
          left: (width - lineWidth) / 2.0,
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
              width: 320.0,
              height: 220.0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Acoustic Ghost Echoes (Phase 3: expanding outward)
                  if (tEcho > 0.0 && echoFade > 0.0) ...[
                    // Ghost 3 (Furthest, scale 1.24, 48dp travel)
                    _buildGhostPair(
                      splitY: 110.0,
                      verticalOffset: 48.0 * tEcho,
                      scale: 1.0 + (0.24 * tEcho),
                      topColor: AppColors.splashGhostTop3,
                      bottomColor: AppColors.splashGhostBottom3,
                      opacity: echoFade,
                    ),
                    // Ghost 2 (Mid, scale 1.16, 32dp travel)
                    _buildGhostPair(
                      splitY: 110.0,
                      verticalOffset: 32.0 * tEcho,
                      scale: 1.0 + (0.16 * tEcho),
                      topColor: AppColors.splashGhostTop2,
                      bottomColor: AppColors.splashGhostBottom2,
                      opacity: echoFade,
                    ),
                    // Ghost 1 (Closest, scale 1.08, 16dp travel)
                    _buildGhostPair(
                      splitY: 110.0,
                      verticalOffset: 16.0 * tEcho,
                      scale: 1.0 + (0.08 * tEcho),
                      topColor: AppColors.splashGhostTop1,
                      bottomColor: AppColors.splashGhostBottom1,
                      opacity: echoFade,
                    ),
                  ],

                  // 2. Primary Dual-Clipped Wordmark
                  // Top copy: white on blue500
                  ClipRect(
                    clipper: _HalfClipper(isTop: true, splitY: 110.0),
                    child: EchoWordmark(
                      color: AppColors.white,
                      letterProgressE: pE,
                      letterProgressC: pC,
                      letterProgressH: pH,
                      letterProgressO: pO,
                      globalOpacity: wordmarkGlobalOpacity,
                    ),
                  ),

                  // Bottom copy: blue500 on white
                  ClipRect(
                    clipper: _HalfClipper(isTop: false, splitY: 110.0),
                    child: EchoWordmark(
                      color: AppColors.blue500,
                      letterProgressE: pE,
                      letterProgressC: pC,
                      letterProgressH: pH,
                      letterProgressO: pO,
                      globalOpacity: wordmarkGlobalOpacity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tagline below the line
        if (taglineOpacity > 0.0)
          Positioned(
            top: splitY + AppSpacing.p40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: taglineOpacity.clamp(0.0, 1.0),
              child: const Center(
                child: Text(
                  'Listen with awareness',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.0,
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
            child: EchoWordmark(
              color: topColor,
              verticalOffset: -verticalOffset,
              scale: scale,
              globalOpacity: opacity,
            ),
          ),
          // Bottom ghost: expands DOWN into white half
          ClipRect(
            clipper: _HalfClipper(isTop: false, splitY: splitY),
            child: EchoWordmark(
              color: bottomColor,
              verticalOffset: verticalOffset,
              scale: scale,
              globalOpacity: opacity,
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
      return Rect.fromLTRB(-100.0, -100.0, size.width + 100.0, splitY);
    } else {
      return Rect.fromLTRB(-100.0, splitY, size.width + 100.0, size.height + 100.0);
    }
  }

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) {
    return oldClipper.isTop != isTop || oldClipper.splitY != splitY;
  }
}
