import 'package:flutter_test/flutter_test.dart';
import 'package:echo/features/test/application/hearing_test_notifier.dart';
import 'package:echo/features/test/domain/models/hearing_threshold_result.dart';

void main() {
  group('HearingTestNotifier Unit Tests', () {
    late HearingTestNotifier notifier;

    setUp(() {
      notifier = HearingTestNotifier();
    });

    test('Initial state is ready with 0 progress and empty results', () {
      final state = notifier.state;
      expect(state.phase, equals(HearingTestPhase.ready));
      expect(state.progress, equals(0.0));
      expect(state.leftEarResults, isEmpty);
      expect(state.rightEarResults, isEmpty);
    });

    test('startTest() sets phase to inProgress on Left ear at frequency 1000Hz and level 3', () {
      notifier.startTest();
      final state = notifier.state;
      expect(state.phase, equals(HearingTestPhase.inProgress));
      expect(state.currentEar, equals(HearingEar.left));
      expect(state.currentFrequency, equals(1000));
      expect(state.currentLevel, equals(3));
    });

    test('recordNoResponse() increments level up to 13', () {
      notifier.startTest();
      expect(notifier.state.currentLevel, equals(3));

      notifier.recordNoResponse();
      expect(notifier.state.currentLevel, equals(4));

      // Step up to level 13
      for (int i = 4; i < 13; i++) {
        notifier.recordNoResponse();
      }
      expect(notifier.state.currentLevel, equals(13));
    });

    test('Disambiguation of Level 13: recordNoResponse() at level 13 records isDetected: false', () {
      notifier.startTest();
      // Increase to level 13
      for (int i = 3; i < 13; i++) {
        notifier.recordNoResponse();
      }
      expect(notifier.state.currentLevel, equals(13));

      // At level 13, another no-response records threshold as not detected
      notifier.recordNoResponse();

      expect(notifier.state.leftEarResults.length, equals(1));
      final result = notifier.state.leftEarResults.first;
      expect(result.frequencyHz, equals(1000));
      expect(result.level, equals(13));
      expect(result.isDetected, isFalse); // Disambiguated!

      // Advanced to next frequency (2000Hz)
      expect(notifier.state.currentFrequency, equals(2000));
      expect(notifier.state.currentLevel, equals(3));
    });

    test('recordResponse() records isDetected: true and advances frequency', () {
      notifier.startTest();
      notifier.recordResponse();

      expect(notifier.state.leftEarResults.length, equals(1));
      final result = notifier.state.leftEarResults.first;
      expect(result.frequencyHz, equals(1000));
      expect(result.level, equals(3));
      expect(result.isDetected, isTrue);

      expect(notifier.state.currentFrequency, equals(2000));
    });

    test('Left ear completion triggers button-driven ear interstitial step', () {
      notifier.startTest();
      // Complete all frequencies for left ear
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }

      expect(notifier.state.phase, equals(HearingTestPhase.earInterstitial));
      expect(notifier.state.leftEarResults.length, equals(kScreeningFrequencies.length));
      expect(notifier.state.rightEarResults, isEmpty);

      // Trigger button action to start right ear
      notifier.startRightEar();

      expect(notifier.state.phase, equals(HearingTestPhase.inProgress));
      expect(notifier.state.currentEar, equals(HearingEar.right));
      expect(notifier.state.currentFrequency, equals(1000));
    });

    test('Right ear completion sets phase to completed with per-ear results preserved', () {
      notifier.startTest();
      // Complete Left ear
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }
      notifier.startRightEar();

      // Complete Right ear
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }

      expect(notifier.state.phase, equals(HearingTestPhase.completed));
      expect(notifier.state.leftEarResults.length, equals(kScreeningFrequencies.length));
      expect(notifier.state.rightEarResults.length, equals(kScreeningFrequencies.length));
      expect(notifier.state.progress, equals(1.0));
    });

    test('pauseTest() and resumeTest() preserve execution state', () {
      notifier.startTest();
      notifier.recordResponse(); // 1st freq done
      expect(notifier.state.currentFrequency, equals(2000));

      notifier.pauseTest();
      expect(notifier.state.phase, equals(HearingTestPhase.paused));

      notifier.resumeTest();
      expect(notifier.state.phase, equals(HearingTestPhase.inProgress));
      expect(notifier.state.currentFrequency, equals(2000));
    });

    test('reset() clears all state back to initial ready state', () {
      notifier.startTest();
      notifier.recordResponse();
      expect(notifier.state.leftEarResults.isNotEmpty, isTrue);

      notifier.reset();
      expect(notifier.state.phase, equals(HearingTestPhase.ready));
      expect(notifier.state.leftEarResults, isEmpty);
      expect(notifier.state.rightEarResults, isEmpty);
      expect(notifier.state.progress, equals(0.0));
    });
  });
}
