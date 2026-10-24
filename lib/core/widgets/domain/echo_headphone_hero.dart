import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum EchoEarTarget { none, left, right, both }

/// Custom-painted modern over-ear headphone hero illustration.
/// Matches the headphone design across Board 1 & Board 2.
/// Fully monochromatic using [AppColors] tokens.
class EchoHeadphoneHero extends StatelessWidget {
  final double size;
  final EchoEarTarget activeEar;
  final bool showBadges;
  final String? semanticLabel;

  const EchoHeadphoneHero({
    super.key,
    this.size = 180.0,
    this.activeEar = EchoEarTarget.none,
    this.showBadges = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Over-ear headphones illustration',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: _HeadphonePainter(
            activeEar: activeEar,
            showBadges: showBadges,
          ),
        ),
      ),
    );
  }
}

class _HeadphonePainter extends CustomPainter {
  final EchoEarTarget activeEar;
  final bool showBadges;

  _HeadphonePainter({
    required this.activeEar,
    required this.showBadges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double scale = w / 200.0;

    final isLeftActive = activeEar == EchoEarTarget.left || activeEar == EchoEarTarget.both;
    final isRightActive = activeEar == EchoEarTarget.right || activeEar == EchoEarTarget.both;

    // 1. Draw Acoustic sound ripples if an ear is active
    if (isLeftActive) {
      _drawAcousticRipples(canvas, Offset(cx - 62 * scale, cy + 18 * scale), -1, scale);
    }
    if (isRightActive) {
      _drawAcousticRipples(canvas, Offset(cx + 62 * scale, cy + 18 * scale), 1, scale);
    }

    // 2. Headband outer arch
    final outerBandPaint = Paint()
      ..color = AppColors.blue400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * scale
      ..strokeCap = StrokeCap.round;

    final bandRect = Rect.fromCenter(
      center: Offset(cx, cy + 8 * scale),
      width: 124 * scale,
      height: 130 * scale,
    );

    // Draw top semi-ellipse arc
    canvas.drawArc(
      bandRect,
      math.pi,
      math.pi,
      false,
      outerBandPaint,
    );

    // 3. Headband cushion padding (inner thick segment)
    final cushionPaint = Paint()
      ..color = AppColors.blue100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0 * scale
      ..strokeCap = StrokeCap.round;

    final cushionRect = Rect.fromCenter(
      center: Offset(cx, cy + 9 * scale),
      width: 116 * scale,
      height: 122 * scale,
    );

    // Cushion covers top 100 degrees of the arch
    canvas.drawArc(
      cushionRect,
      math.pi + (40 * math.pi / 180),
      100 * math.pi / 180,
      false,
      cushionPaint,
    );

    // 4. Slider extenders (connecting band to yokes)
    final sliderPaint = Paint()
      ..color = AppColors.borderFunctional
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round;

    // Left slider
    canvas.drawLine(
      Offset(cx - 62 * scale, cy + 8 * scale),
      Offset(cx - 62 * scale, cy + 28 * scale),
      sliderPaint,
    );

    // Right slider
    canvas.drawLine(
      Offset(cx + 62 * scale, cy + 8 * scale),
      Offset(cx + 62 * scale, cy + 28 * scale),
      sliderPaint,
    );

    // 5. Left Ear Cup & Cushion
    _drawEarCup(
      canvas: canvas,
      center: Offset(cx - 62 * scale, cy + 28 * scale),
      scale: scale,
      isActive: isLeftActive,
      badgeLabel: showBadges ? 'L' : null,
      isLeft: true,
    );

    // 6. Right Ear Cup & Cushion
    _drawEarCup(
      canvas: canvas,
      center: Offset(cx + 62 * scale, cy + 28 * scale),
      scale: scale,
      isActive: isRightActive,
      badgeLabel: showBadges ? 'R' : null,
      isLeft: false,
    );
  }

  void _drawEarCup({
    required Canvas canvas,
    required Offset center,
    required double scale,
    required bool isActive,
    required String? badgeLabel,
    required bool isLeft,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Gentle inward tilt angle
    final double tilt = (isLeft ? 6.0 : -6.0) * math.pi / 180;
    canvas.rotate(tilt);

    final cupWidth = 32.0 * scale;
    final cupHeight = 56.0 * scale;
    final cupRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cupWidth, height: cupHeight),
      Radius.circular(16.0 * scale),
    );

    // Outer cup housing fill
    final housingPaint = Paint()
      ..color = isActive ? AppColors.blue100 : AppColors.surfaceSubtle
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cupRRect, housingPaint);

    // Outer cup housing border
    final borderPaint = Paint()
      ..color = isActive ? AppColors.blue500 : AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isActive ? 2.5 : 1.5) * scale;
    canvas.drawRRect(cupRRect, borderPaint);

    // Inner cushion ring
    final innerCushionRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 22.0 * scale, height: 42.0 * scale),
      Radius.circular(11.0 * scale),
    );
    final innerCushionPaint = Paint()
      ..color = isActive ? AppColors.white : AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawRRect(innerCushionRRect, innerCushionPaint);

    final innerBorderPaint = Paint()
      ..color = isActive ? AppColors.blue400 : AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawRRect(innerCushionRRect, innerBorderPaint);

    // Ear Badge (L / R)
    if (badgeLabel != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: badgeLabel,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0 * scale,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.blue500 : AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    }

    canvas.restore();
  }

  void _drawAcousticRipples(Canvas canvas, Offset cupCenter, double direction, double scale) {
    final ripplePaint = Paint()
      ..color = AppColors.blue300
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double startAngle = direction < 0 ? (math.pi - 0.7) : -0.7;
    const double sweepAngle = 1.4;

    // Ripple 1
    ripplePaint.strokeWidth = 2.0 * scale;
    canvas.drawArc(
      Rect.fromCircle(center: cupCenter, radius: 28.0 * scale),
      startAngle,
      sweepAngle,
      false,
      ripplePaint,
    );

    // Ripple 2
    ripplePaint.strokeWidth = 1.5 * scale;
    ripplePaint.color = AppColors.blue200;
    canvas.drawArc(
      Rect.fromCircle(center: cupCenter, radius: 38.0 * scale),
      startAngle,
      sweepAngle,
      false,
      ripplePaint,
    );

    // Ripple 3
    ripplePaint.strokeWidth = 1.0 * scale;
    ripplePaint.color = AppColors.blue100;
    canvas.drawArc(
      Rect.fromCircle(center: cupCenter, radius: 48.0 * scale),
      startAngle,
      sweepAngle,
      false,
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeadphonePainter oldDelegate) {
    return oldDelegate.activeEar != activeEar || oldDelegate.showBadges != showBadges;
  }
}
