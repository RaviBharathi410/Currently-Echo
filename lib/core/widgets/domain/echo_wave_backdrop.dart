import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Multi-layered harmonic acoustic wave illustration for backgrounds.
/// Matches the wave accents seen in Board 1 Screen 8 and Board 2 Screen 1.
/// Drawn purely in code via [CustomPainter] using [AppColors] tokens.
class EchoWaveBackdrop extends StatelessWidget {
  final double height;
  final Widget? child;

  const EchoWaveBackdrop({
    super.key,
    this.height = 140.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: const _EchoWavePainter(),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _EchoWavePainter extends CustomPainter {
  const _EchoWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Layer 1: Deep subtle wave
    final wave1Paint = Paint()
      ..color = AppColors.backdropTintA
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, h * 0.55);
    path1.cubicTo(
      w * 0.25, h * 0.35,
      w * 0.45, h * 0.75,
      w * 0.70, h * 0.50,
    );
    path1.cubicTo(
      w * 0.85, h * 0.35,
      w * 0.95, h * 0.45,
      w, h * 0.40,
    );
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Layer 2: Secondary harmonic wave
    final wave2Paint = Paint()
      ..color = AppColors.backdropTintB
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, h * 0.68);
    path2.cubicTo(
      w * 0.30, h * 0.82,
      w * 0.55, h * 0.45,
      w * 0.80, h * 0.65,
    );
    path2.cubicTo(
      w * 0.90, h * 0.75,
      w * 0.98, h * 0.60,
      w, h * 0.58,
    );
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();
    canvas.drawPath(path2, wave2Paint);

    // Layer 3: Crisp subtle crest line
    final crestPaint = Paint()
      ..color = AppColors.backdropWave
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crestPath = Path();
    crestPath.moveTo(0, h * 0.68);
    crestPath.cubicTo(
      w * 0.30, h * 0.82,
      w * 0.55, h * 0.45,
      w * 0.80, h * 0.65,
    );
    crestPath.cubicTo(
      w * 0.90, h * 0.75,
      w * 0.98, h * 0.60,
      w, h * 0.58,
    );
    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
