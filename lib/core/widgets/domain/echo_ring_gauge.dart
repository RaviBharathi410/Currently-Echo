import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Circular arc gauge used in Sound Monitoring.
/// Matches Board 1 Screen 8.
/// Non-negotiable constraint: zero clinical claims, zero 'dB' references.
/// Resilient to 200% font scale via FittedBox centering.
class EchoRingGauge extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final String levelLabel; // e.g. "Level 3 of 5"
  final String statusLabel; // e.g. "Moderate, sample"
  final IconData? centerIcon;

  const EchoRingGauge({
    super.key,
    required this.value,
    this.size = 220.0,
    this.levelLabel = 'Level 3 of 5',
    this.statusLabel = 'Moderate, sample',
    this.centerIcon = Icons.graphic_eq_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return Semantics(
      label: 'Sound level gauge: $levelLabel, status: $statusLabel',
      value: '${(clampedValue * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gauge Arc
            CustomPaint(
              size: Size(size, size),
              painter: _RingGaugePainter(
                progress: clampedValue,
                trackColor: AppColors.surfaceSubtle,
                progressColor: AppColors.blue500,
              ),
            ),

            // Inner Content (scaled down gracefully if text scale is huge)
            Padding(
              padding: EdgeInsets.all(size * 0.15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (centerIcon != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.p8),
                        decoration: const BoxDecoration(
                          color: AppColors.blue100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          centerIcon,
                          size: 24.0,
                          color: AppColors.blue500,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      levelLabel,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    // Status pill badge (tonal blue, never green)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p8,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        borderRadius: AppRadii.roundedPill,
                        border: Border.all(color: AppColors.blue400, width: 1.0),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.captionBold.copyWith(
                          color: AppColors.blue500,
                          fontSize: 10.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  // Gauge starts at 135 degrees (bottom-left) and sweeps 270 degrees to bottom-right
  static const double _startAngle = 135.0 * math.pi / 180.0;
  static const double _totalSweep = 270.0 * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.085;
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _totalSweep,
      false,
      trackPaint,
    );

    // Draw active progress
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _startAngle,
        _totalSweep * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
