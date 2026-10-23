enum HearingEar {
  left,
  right;

  String get label => this == HearingEar.left ? 'Left Ear' : 'Right Ear';
}

enum HearingTestPhase {
  ready,
  inProgress,
  earInterstitial,
  paused,
  completed,
}

class HearingThresholdResult {
  final int frequencyHz;
  final int level; // 1 to 13 relative levels
  final bool isDetected; // true = detected at level, false = inaudible at max screening limit

  const HearingThresholdResult({
    required this.frequencyHz,
    required this.level,
    required this.isDetected,
  });

  @override
  String toString() {
    return 'HearingThresholdResult(freq: ${frequencyHz}Hz, level: $level, detected: $isDetected)';
  }
}

/// The 6 canonical screening frequencies presented during preliminary testing.
/// Begins at 1000 Hz (the clinical screening reference), followed by high frequencies,
/// then low frequencies: [1000, 2000, 4000, 8000, 500, 250].
const List<int> kScreeningFrequencies = [1000, 2000, 4000, 8000, 500, 250];

