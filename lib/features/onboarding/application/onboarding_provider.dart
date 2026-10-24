import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final bool isOnboardingComplete;
  final int currentStep;
  // Profile data
  final String? preferredName;
  final String? ageRange;
  final String? preferredLanguage;
  // Disclaimer acceptance
  final bool disclaimerAccepted;
  // Permissions flags
  final bool microphoneGranted;
  final bool notificationsGranted;
  final bool bluetoothGranted;
  // Device connection state
  final bool deviceConnected;

  const OnboardingState({
    this.isOnboardingComplete = false,
    this.currentStep = 0,
    this.preferredName,
    this.ageRange,
    this.preferredLanguage,
    this.disclaimerAccepted = false,
    this.microphoneGranted = false,
    this.notificationsGranted = false,
    this.bluetoothGranted = false,
    this.deviceConnected = false,
  });

  OnboardingState copyWith({
    bool? isOnboardingComplete,
    int? currentStep,
    String? preferredName,
    String? ageRange,
    String? preferredLanguage,
    bool? disclaimerAccepted,
    bool? microphoneGranted,
    bool? notificationsGranted,
    bool? bluetoothGranted,
    bool? deviceConnected,
  }) {
    return OnboardingState(
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      currentStep: currentStep ?? this.currentStep,
      preferredName: preferredName ?? this.preferredName,
      ageRange: ageRange ?? this.ageRange,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      bluetoothGranted: bluetoothGranted ?? this.bluetoothGranted,
      deviceConnected: deviceConnected ?? this.deviceConnected,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier({bool initialComplete = false})
      : super(OnboardingState(isOnboardingComplete: initialComplete));

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setProfile({String? name, String? age, String? language}) {
    state = state.copyWith(
      preferredName: name,
      ageRange: age,
      preferredLanguage: language,
    );
  }

  void acceptDisclaimer(bool accepted) {
    state = state.copyWith(disclaimerAccepted: accepted);
  }

  void setPermissions({bool? mic, bool? notif, bool? bt}) {
    state = state.copyWith(
      microphoneGranted: mic ?? state.microphoneGranted,
      notificationsGranted: notif ?? state.notificationsGranted,
      bluetoothGranted: bt ?? state.bluetoothGranted,
    );
  }

  void setDeviceConnection(bool connected) {
    state = state.copyWith(deviceConnected: connected);
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboardingComplete: true);
  }

  void resetOnboarding() {
    state = const OnboardingState(isOnboardingComplete: false, currentStep: 0);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
