import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';

class SoundWaveBarConfig {
  final double minHeight;
  final double maxHeight;
  final Color color;

  const SoundWaveBarConfig({
    required this.minHeight,
    required this.maxHeight,
    required this.color,
  });
}

const List<SoundWaveBarConfig> kDefaultWaveBars = [
  SoundWaveBarConfig(minHeight: 16.0, maxHeight: 32.0, color: AppColors.blue200),
  SoundWaveBarConfig(minHeight: 24.0, maxHeight: 48.0, color: AppColors.blue300),
  SoundWaveBarConfig(minHeight: 36.0, maxHeight: 62.0, color: AppColors.blue400),
  SoundWaveBarConfig(minHeight: 48.0, maxHeight: 76.0, color: AppColors.blue500),
  SoundWaveBarConfig(minHeight: 36.0, maxHeight: 62.0, color: AppColors.blue400),
  SoundWaveBarConfig(minHeight: 24.0, maxHeight: 48.0, color: AppColors.blue300),
  SoundWaveBarConfig(minHeight: 16.0, maxHeight: 32.0, color: AppColors.blue200),
];

/// A pulsing sound-wave hero widget representing acoustic tone screening.
/// - 7 vertical harmonic acoustic bars with rounded pill caps.
/// - Smooth organic pulsing animation using sine-wave harmonic phase offsets.
/// - Strictly respects Reduce Motion (`disableAnimations`): freezes at balanced static harmonic heights.
/// - Screen-reader safe: decorative animation ticks excluded from semantics.
class SoundWaveHero extends StatefulWidget {
  final double barWidth;
  final double spacing;
  final double containerHeight;
  final List<SoundWaveBarConfig> bars;
  final bool? animate;
  final bool animateInTest;

  const SoundWaveHero({
    super.key,
    this.barWidth = 8.0,
    this.spacing = 6.0,
    this.containerHeight = 84.0,
    this.bars = kDefaultWaveBars,
    this.animate,
    this.animateInTest = false,
  });

  @override
  State<SoundWaveHero> createState() => _SoundWaveHeroState();
}

class _SoundWaveHeroState extends State<SoundWaveHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  bool _checkShouldAnimate() {
    if (widget.animate != null) return widget.animate!;
    if (MediaQuery.disableAnimationsOf(context)) return false;
    final bool isTestBinding = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTestBinding && !widget.animateInTest) return false;
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkShouldAnimate()) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldAnimate = _checkShouldAnimate();

    return Semantics(
      label: 'Acoustic sound wave visualization',
      excludeSemantics: true,
      child: SizedBox(
        height: widget.containerHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(widget.bars.length, (index) {
                final bar = widget.bars[index];
                double barHeight;

                if (!shouldAnimate) {
                  // Static balanced harmonic profile under Reduce Motion or static mode
                  barHeight = (bar.minHeight + bar.maxHeight) * 0.5;
                } else {
                  // Harmonic phase offset across the 7 bars
                  final phase = (index * 0.55);
                  final double t = (math.sin((_controller.value * 2 * math.pi) + phase) + 1.0) / 2.0;
                  barHeight = bar.minHeight + (bar.maxHeight - bar.minHeight) * t;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: Container(
                    width: widget.barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: bar.color,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
