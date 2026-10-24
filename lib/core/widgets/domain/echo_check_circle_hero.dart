import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// Large central check badge with orbiting tonal blue confetti dots.
/// Matches Board 1 Screen 11 ("Left Ear Complete") and Screen 13 ("Screening Complete").
/// Enforces non-negotiable rule: confetti dots are strictly tonal blues (blue200-blue500).
class EchoCheckCircleHero extends StatelessWidget {
  final double size;
  final String? semanticLabel;

  const EchoCheckCircleHero({
    super.key,
    this.size = 140.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Screening section complete checkmark',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Orbiting tonal blue confetti particles
            CustomPaint(
              size: Size(size, size),
              painter: const _ConfettiPainter(),
            ),

            // Central solid blue badge
            Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: AppColors.blue500,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft,
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: size * 0.32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final double angle; // In radians
  final double distanceRatio; // Relative to half-width
  final double radius; // Dot radius
  final Color color;

  const _ConfettiParticle({
    required this.angle,
    required this.distanceRatio,
    required this.radius,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  // Tonal blue confetti layout (angles in degrees converted to radians)
  static final List<_ConfettiParticle> _particles = [
    // Top-right cluster
    _ConfettiParticle(angle: -0.35, distanceRatio: 0.82, radius: 4.0, color: AppColors.blue400),
    _ConfettiParticle(angle: -0.80, distanceRatio: 0.90, radius: 3.0, color: AppColors.blue300),
    _ConfettiParticle(angle: -1.25, distanceRatio: 0.78, radius: 5.0, color: AppColors.blue200),
    // Top-left cluster
    _ConfettiParticle(angle: -2.00, distanceRatio: 0.85, radius: 4.5, color: AppColors.blue500),
    _ConfettiParticle(angle: -2.45, distanceRatio: 0.92, radius: 3.5, color: AppColors.blue300),
    _ConfettiParticle(angle: -2.85, distanceRatio: 0.76, radius: 4.0, color: AppColors.blue200),
    // Bottom-left cluster
    _ConfettiParticle(angle: 2.30, distanceRatio: 0.84, radius: 4.0, color: AppColors.blue400),
    _ConfettiParticle(angle: 2.80, distanceRatio: 0.90, radius: 3.0, color: AppColors.blue200),
    // Bottom-right cluster
    _ConfettiParticle(angle: 0.45, distanceRatio: 0.80, radius: 5.0, color: AppColors.blue300),
    _ConfettiParticle(angle: 0.95, distanceRatio: 0.92, radius: 3.5, color: AppColors.blue500),
    _ConfettiParticle(angle: 1.40, distanceRatio: 0.86, radius: 4.0, color: AppColors.blue200),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (final p in _particles) {
      final dx = center.dx + math.cos(p.angle) * (maxRadius * p.distanceRatio);
      final dy = center.dy + math.sin(p.angle) * (maxRadius * p.distanceRatio);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
