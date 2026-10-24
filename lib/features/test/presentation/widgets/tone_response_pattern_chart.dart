import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/hearing_threshold_result.dart';

/// Monochromatic step curve chart displaying Tone Response Pattern.
/// Matches Board 1 Screen 13.
/// Displays relative sound levels (Level 1 to 13) across test frequencies.
/// Non-negotiables: Strictly zero 'dB' references, zero clinical claims.
class ToneResponsePatternChart extends StatelessWidget {
  final List<HearingThresholdResult> leftEarResults;
  final List<HearingThresholdResult> rightEarResults;
  final double height;

  const ToneResponsePatternChart({
    super.key,
    required this.leftEarResults,
    required this.rightEarResults,
    this.height = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tone response pattern chart illustrating relative sound detection levels across speech frequencies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem('Left Ear', AppColors.blue500, isCircle: true),
              const SizedBox(width: AppSpacing.p16),
              _buildLegendItem('Right Ear', AppColors.blue300, isCircle: false),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),

          // Main Chart Canvas
          Container(
            height: height,
            padding: const EdgeInsets.only(left: AppSpacing.p8, right: AppSpacing.p12, top: AppSpacing.p8, bottom: AppSpacing.p4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: CustomPaint(
              size: Size(double.infinity, height),
              painter: _PatternChartPainter(
                leftResults: leftEarResults,
                rightResults: rightEarResults,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.p6),
          const EchoXAxisLabels(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isCircle}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: AppSpacing.p6),
        Text(
          label,
          style: AppTypography.captionBold.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class EchoXAxisLabels extends StatelessWidget {
  const EchoXAxisLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: kScreeningFrequencies.map((freq) {
          final text = freq >= 1000 ? '${freq ~/ 1000}k' : '$freq';
          return Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.0,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PatternChartPainter extends CustomPainter {
  final List<HearingThresholdResult> leftResults;
  final List<HearingThresholdResult> rightResults;

  _PatternChartPainter({
    required this.leftResults,
    required this.rightResults,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final gridPaint = Paint()
      ..color = AppColors.borderFunctional
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines (4 level markers: 1, 4, 8, 13)
    for (int i = 0; i <= 3; i++) {
      final y = h * (i / 3.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final freqs = kScreeningFrequencies;
    if (freqs.isEmpty) return;

    final double stepX = freqs.length > 1 ? w / (freqs.length - 1) : w;

    // Helper to calculate Y position for level (1..13)
    double getYForLevel(int level) {
      final clamped = level.clamp(1, 13);
      // Level 1 at top (y = 10), Level 13 at bottom (y = h - 10)
      return 10.0 + ((clamped - 1) / 12.0) * (h - 20.0);
    }

    // Draw Left Ear Path & Points (Solid Royal Blue)
    _drawSeries(
      canvas: canvas,
      results: leftResults,
      freqs: freqs,
      stepX: stepX,
      getY: getYForLevel,
      color: AppColors.blue500,
      isCircle: true,
      isDashed: false,
    );

    // Draw Right Ear Path & Points (Tonal Blue)
    _drawSeries(
      canvas: canvas,
      results: rightResults,
      freqs: freqs,
      stepX: stepX,
      getY: getYForLevel,
      color: AppColors.blue300,
      isCircle: false,
      isDashed: true,
    );
  }

  void _drawSeries({
    required Canvas canvas,
    required List<HearingThresholdResult> results,
    required List<int> freqs,
    required double stepX,
    required double Function(int) getY,
    required Color color,
    required bool isCircle,
    required bool isDashed,
  }) {
    if (results.isEmpty) return;

    final resultMap = {for (final r in results) r.frequencyHz: r.level};

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointFillPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final points = <Offset>[];
    for (int i = 0; i < freqs.length; i++) {
      final freq = freqs[i];
      final level = resultMap[freq] ?? 3; // Default sample level 3 if not yet tested
      points.add(Offset(i * stepX, getY(level)));
    }

    // Draw connecting line
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw point markers
    for (final pt in points) {
      if (isCircle) {
        canvas.drawCircle(pt, 5.0, pointFillPaint);
        canvas.drawCircle(pt, 5.0, pointStrokePaint);
      } else {
        final rect = Rect.fromCenter(center: pt, width: 9.0, height: 9.0);
        canvas.drawRect(rect, pointFillPaint);
        canvas.drawRect(rect, pointStrokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternChartPainter oldDelegate) {
    return oldDelegate.leftResults != leftResults || oldDelegate.rightResults != rightResults;
  }
}
