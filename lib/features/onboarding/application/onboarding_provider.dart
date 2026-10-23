import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final bool isOnboardingComplete;
  final int currentStep;

  const OnboardingState({
    this.isOnboardingComplete = false,
    this.currentStep = 0,
  });

  OnboardingState copyWith({
    bool? isOnboardingComplete,
    int? currentStep,
  }) {
    return OnboardingState(
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier({bool initialComplete = false})
      : super(OnboardingState(isOnboardingComplete: initialComplete));

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
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
