import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/hearing_threshold_result.dart';

class HearingTestState {
  final HearingTestPhase phase;
  final HearingTestPhase? phaseBeforePause;
  final HearingEar currentEar;
  final int currentFrequencyIndex;
  final int currentLevel; // 1 to 13
  final List<HearingThresholdResult> leftEarResults;
  final List<HearingThresholdResult> rightEarResults;
  final List<int> frequencies;

  const HearingTestState({
    this.phase = HearingTestPhase.ready,
    this.phaseBeforePause,
    this.currentEar = HearingEar.left,
    this.currentFrequencyIndex = 0,
    this.currentLevel = 3,
    this.leftEarResults = const [],
    this.rightEarResults = const [],
    this.frequencies = kScreeningFrequencies,
  });

  int get currentFrequency => frequencies[currentFrequencyIndex];

  double get progress {
    final totalSteps = frequencies.length * 2;
    final completedSteps = leftEarResults.length + rightEarResults.length;
    return (completedSteps / totalSteps).clamp(0.0, 1.0);
  }

  HearingTestState copyWith({
    HearingTestPhase? phase,
    HearingTestPhase? phaseBeforePause,
    HearingEar? currentEar,
    int? currentFrequencyIndex,
    int? currentLevel,
    List<HearingThresholdResult>? leftEarResults,
    List<HearingThresholdResult>? rightEarResults,
    List<int>? frequencies,
  }) {
    return HearingTestState(
      phase: phase ?? this.phase,
      phaseBeforePause: phaseBeforePause ?? this.phaseBeforePause,
      currentEar: currentEar ?? this.currentEar,
      currentFrequencyIndex: currentFrequencyIndex ?? this.currentFrequencyIndex,
      currentLevel: currentLevel ?? this.currentLevel,
      leftEarResults: leftEarResults ?? this.leftEarResults,
      rightEarResults: rightEarResults ?? this.rightEarResults,
      frequencies: frequencies ?? this.frequencies,
    );
  }
}

class HearingTestNotifier extends StateNotifier<HearingTestState> {
  HearingTestNotifier() : super(const HearingTestState());

  void startTest() {
    state = const HearingTestState(
      phase: HearingTestPhase.inProgress,
      currentEar: HearingEar.left,
      currentFrequencyIndex: 0,
      currentLevel: 3,
      leftEarResults: [],
      rightEarResults: [],
    );
  }

  void recordResponse() {
    if (state.phase != HearingTestPhase.inProgress) return;

    final result = HearingThresholdResult(
      frequencyHz: state.currentFrequency,
      level: state.currentLevel,
      isDetected: true,
    );

    _saveResultAndAdvance(result);
  }

  void recordNoResponse() {
    if (state.phase != HearingTestPhase.inProgress) return;

    if (state.currentLevel < 13) {
      // Increment sound level
      state = state.copyWith(currentLevel: state.currentLevel + 1);
    } else {
      // Reached maximum limit without detection: record isDetected: false
      final result = HearingThresholdResult(
        frequencyHz: state.currentFrequency,
        level: 13,
        isDetected: false,
      );
      _saveResultAndAdvance(result);
    }
  }

  void _saveResultAndAdvance(HearingThresholdResult result) {
    if (state.currentEar == HearingEar.left) {
      final updatedLeft = [...state.leftEarResults, result];
      final nextFreqIndex = state.currentFrequencyIndex + 1;

      if (nextFreqIndex < state.frequencies.length) {
        state = state.copyWith(
          leftEarResults: updatedLeft,
          currentFrequencyIndex: nextFreqIndex,
          currentLevel: 3,
        );
      } else {
        // Left ear finished -> Button-driven interstitial before Right ear
        state = state.copyWith(
          leftEarResults: updatedLeft,
          phase: HearingTestPhase.earInterstitial,
          currentFrequencyIndex: 0,
          currentLevel: 3,
        );
      }
    } else {
      final updatedRight = [...state.rightEarResults, result];
      final nextFreqIndex = state.currentFrequencyIndex + 1;

      if (nextFreqIndex < state.frequencies.length) {
        state = state.copyWith(
          rightEarResults: updatedRight,
          currentFrequencyIndex: nextFreqIndex,
          currentLevel: 3,
        );
      } else {
        // Both ears complete!
        state = state.copyWith(
          rightEarResults: updatedRight,
          phase: HearingTestPhase.completed,
        );
      }
    }
  }

  void startRightEar() {
    state = state.copyWith(
      phase: HearingTestPhase.inProgress,
      currentEar: HearingEar.right,
      currentFrequencyIndex: 0,
      currentLevel: 3,
    );
  }

  void pauseTest() {
    if (state.phase != HearingTestPhase.paused) {
      state = state.copyWith(
        phaseBeforePause: state.phase,
        phase: HearingTestPhase.paused,
      );
    }
  }

  void resumeTest() {
    if (state.phase == HearingTestPhase.paused) {
      state = state.copyWith(
        phase: state.phaseBeforePause ?? HearingTestPhase.inProgress,
        phaseBeforePause: null,
      );
    }
  }

  void reset() {
    state = const HearingTestState();
  }
}

final hearingTestProvider =
    StateNotifierProvider<HearingTestNotifier, HearingTestState>((ref) {
  return HearingTestNotifier();
});
