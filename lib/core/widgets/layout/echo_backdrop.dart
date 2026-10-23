import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Lightweight ambient atmospheric backdrop for ECHO.
///
/// Features:
/// 1. Base fill in [AppColors.surface]
/// 2. Soft radial gradient tints using named tokens [AppColors.backdropTintA],
///    [AppColors.backdropTintB], and [AppColors.backdropTintCenter]
/// 3. Subtle acoustic wave arcs near the bottom in [AppColors.backdropWave]
/// 4. Optional 60s slow drift (< 16dp travel), fully disabled when
///    [MediaQuery.disableAnimationsOf] is active.
///
/// Wrapped in [RepaintBoundary] and [ExcludeSemantics] for zero accessibility
/// or layout overhead.
class EchoBackdrop extends StatefulWidget {
  final bool enableDrift;

  const EchoBackdrop({
    super.key,
    this.enableDrift = false,
  });

  @override
  State<EchoBackdrop> createState() => _EchoBackdropState();
}

class _EchoBackdropState extends State<EchoBackdrop>
    with SingleTickerProviderStateMixin {
  AnimationController? _driftController;

  @override
  void initState() {
    super.initState();
    if (widget.enableDrift) {
      _initDrift();
    }
  }

  void _initDrift() {
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void didUpdateWidget(EchoBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableDrift && _driftController == null) {
      _initDrift();
    } else if (!widget.enableDrift && _driftController != null) {
      _driftController?.dispose();
      _driftController = null;
    }
  }

  @override
  void dispose() {
    _driftController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations || !widget.enableDrift || _driftController == null) {
      return const ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: EchoBackdropPainter(driftProgress: 0.0),
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _driftController!,
        builder: (context, child) {
          return RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: EchoBackdropPainter(
                driftProgress: _driftController!.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Standalone painter for EchoBackdrop so it can be evaluated, tested,
/// and sampled deterministically in isolation.
class EchoBackdropPainter extends CustomPainter {
  final double driftProgress;

  const EchoBackdropPainter({this.driftProgress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base fill: AppColors.surface
    final basePaint = Paint()..color = AppColors.surface;
    canvas.drawRect(Offset.zero & size, basePaint);

    if (size.width <= 0 || size.height <= 0) return;

    // Calculate subtle cyclic drift offset (< 16dp total travel)
    final double driftAngle = driftProgress * 2.0 * math.pi;
    final double driftX = math.sin(driftAngle) * 7.0;
    final double driftY = math.cos(driftAngle) * 7.0;

    // 2. Large soft radial tints
    // Top-right tint
    final trCenter = Offset(
      size.width * 0.85 + driftX,
      size.height * 0.15 + driftY,
    );
    final trRadius = size.width * 0.75;
    final trPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          AppColors.backdropTintA,
          AppColors.backdropFade,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: trCenter, radius: trRadius));
    canvas.drawCircle(trCenter, trRadius, trPaint);

    // Lower-left tint
    final llCenter = Offset(
      size.width * 0.15 - driftX,
      size.height * 0.75 - driftY,
    );
    final llRadius = size.width * 0.80;
    final llPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          AppColors.backdropTintB,
          AppColors.backdropFade,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: llCenter, radius: llRadius));
    canvas.drawCircle(llCenter, llRadius, llPaint);

    // Subtle center ambient tint
    final cCenter = Offset(
      size.width * 0.50,
      size.height * 0.45 + (driftY * 0.5),
    );
    final cRadius = size.width * 0.65;
    final cPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          AppColors.backdropTintCenter,
          AppColors.backdropFade,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: cCenter, radius: cRadius));
    canvas.drawCircle(cCenter, cRadius, cPaint);

    // 3. Faint acoustic wave arc motif near bottom
    final wavePaint = Paint()
      ..color = AppColors.backdropWave
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    final double waveBaseY1 = size.height * 0.88;
    path1.moveTo(-size.width * 0.1, waveBaseY1 + driftY * 0.4);
    path1.cubicTo(
      size.width * 0.25,
      waveBaseY1 - 18.0 + driftY * 0.4,
      size.width * 0.70,
      waveBaseY1 + 16.0 - driftY * 0.4,
      size.width * 1.1,
      waveBaseY1 - 8.0,
    );
    canvas.drawPath(path1, wavePaint);

    final path2 = Path();
    final double waveBaseY2 = size.height * 0.93;
    path2.moveTo(-size.width * 0.05, waveBaseY2 - 10.0);
    path2.cubicTo(
      size.width * 0.35,
      waveBaseY2 + 14.0 - driftY * 0.3,
      size.width * 0.65,
      waveBaseY2 - 14.0 + driftY * 0.3,
      size.width * 1.05,
      waveBaseY2 + 4.0,
    );
    canvas.drawPath(path2, wavePaint);
  }

  @override
  bool shouldRepaint(covariant EchoBackdropPainter oldDelegate) {
    return oldDelegate.driftProgress != driftProgress;
  }
}
