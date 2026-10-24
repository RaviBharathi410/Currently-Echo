import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Concentric acoustic glow rings representing sound emission.
/// Matches Board 1 Screens 10 & 12 (hearing test in progress).
/// Monochromatic design using [AppColors] tokens.
class EchoGlowRings extends StatefulWidget {
  final Widget? child;
  final double size;
  final bool isPulsing;
  final bool animateInTest;

  const EchoGlowRings({
    super.key,
    this.child,
    this.size = 240.0,
    this.isPulsing = false,
    this.animateInTest = false,
  });

  @override
  State<EchoGlowRings> createState() => _EchoGlowRingsState();
}

class _EchoGlowRingsState extends State<EchoGlowRings>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  bool _checkShouldAnimate() {
    if (!widget.isPulsing) return false;
    if (MediaQuery.disableAnimationsOf(context)) return false;
    final bool isTestBinding = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTestBinding && !widget.animateInTest) return false;
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkShouldAnimate()) {
      if (!(_controller?.isAnimating ?? false)) {
        _controller?.repeat();
      }
    } else {
      if (_controller?.isAnimating ?? false) {
        _controller?.stop();
        _controller?.reset();
      }
    }
  }

  @override
  void didUpdateWidget(covariant EchoGlowRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (_checkShouldAnimate()) {
        _controller?.repeat();
      } else {
        _controller?.stop();
        _controller?.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = _checkShouldAnimate();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!shouldAnimate)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: const _StaticRingsPainter(),
            )
          else if (_controller != null)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _PulsingRingsPainter(progress: _controller!.value),
                );
              },
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _StaticRingsPainter extends CustomPainter {
  const _StaticRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Ring 1 (innermost, clearest)
    canvas.drawCircle(
      center,
      maxRadius * 0.58,
      Paint()
        ..color = AppColors.blue200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Ring 2 (mid)
    canvas.drawCircle(
      center,
      maxRadius * 0.78,
      Paint()
        ..color = AppColors.blue100
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Ring 3 (outermost, faintest)
    canvas.drawCircle(
      center,
      maxRadius * 0.96,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingRingsPainter extends CustomPainter {
  final double progress;

  _PulsingRingsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.33)) % 1.0;
      final radius = maxRadius * (0.45 + 0.52 * ringProgress);

      final Color ringColor;
      if (ringProgress < 0.33) {
        ringColor = AppColors.blue200;
      } else if (ringProgress < 0.66) {
        ringColor = AppColors.blue100;
      } else {
        ringColor = AppColors.border;
      }

      final paint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2.0 * (1.0 - ringProgress * 0.5));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsingRingsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
