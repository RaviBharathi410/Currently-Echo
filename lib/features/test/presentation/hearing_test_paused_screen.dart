import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../onboarding/application/onboarding_provider.dart';
import '../application/hearing_test_notifier.dart';

class HearingTestPausedScreen extends ConsumerWidget {
  const HearingTestPausedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const EchoAppBar(
          title: 'Test Paused',
          showBackButton: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.pause_circle_outline,
                    size: 72.0,
                    color: AppColors.blue500,
                  ),
                  const SizedBox(height: AppSpacing.p20),
                  const EchoText(
                    'Screening Paused',
                    variant: EchoTextStyleVariant.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  const EchoText(
                    'Your session is paused. You can resume testing at any time, or exit and return later.',
                    variant: EchoTextStyleVariant.bodyMedium,
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.p32),
                  EchoButton(
                    label: 'Resume Screening',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      ref.read(hearingTestProvider.notifier).resumeTest();
                      context.pop();
                    },
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  EchoButton(
                    label: 'Exit Screening',
                    variant: EchoButtonVariant.secondary,
                    icon: Icons.close,
                    onPressed: () {
                      final isOnboarded =
                          ref.read(onboardingProvider).isOnboardingComplete;
                      ref.read(hearingTestProvider.notifier).reset();
                      if (isOnboarded) {
                        context.go('/test');
                      } else {
                        context.go('/onboarding/test-intro');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
