import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

/// Renders the "ECHO" wordmark with per-letter slide and fade animations.
///
/// Letters 'E', 'C', 'H', 'O' can be staggered during reveal, scaled for acoustic
/// ghost echo effects, and colored independently for split-horizon clipping.
class EchoWordmark extends StatelessWidget {
  final Color color;
  final double letterProgressE;
  final double letterProgressC;
  final double letterProgressH;
  final double letterProgressO;
  final double globalOpacity;
  final double verticalOffset;
  final double scale;

  const EchoWordmark({
    super.key,
    required this.color,
    this.letterProgressE = 1.0,
    this.letterProgressC = 1.0,
    this.letterProgressH = 1.0,
    this.letterProgressO = 1.0,
    this.globalOpacity = 1.0,
    this.verticalOffset = 0.0,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    const letters = ['E', 'C', 'H', 'O'];
    final progresses = [
      letterProgressE,
      letterProgressC,
      letterProgressH,
      letterProgressO,
    ];

    final textStyle = AppTypography.wordmark.copyWith(color: color);

    return Transform.scale(
      scale: scale,
      child: Transform.translate(
        offset: Offset(0.0, verticalOffset),
        child: Opacity(
          opacity: globalOpacity.clamp(0.0, 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(4, (index) {
              final p = progresses[index].clamp(0.0, 1.0);
              // Letters slide upward by up to 14dp as they fade in
              final slideY = (1.0 - p) * 14.0;
              return Opacity(
                opacity: p,
                child: Transform.translate(
                  offset: Offset(0.0, slideY),
                  child: Text(
                    letters[index],
                    style: textStyle,
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
