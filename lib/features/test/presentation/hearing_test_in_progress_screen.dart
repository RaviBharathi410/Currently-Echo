import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';
import '../application/hearing_test_notifier.dart';
import '../domain/models/hearing_threshold_result.dart';

class HearingTestInProgressScreen extends ConsumerWidget {
  const HearingTestInProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hearingTestProvider);

    // If screening is complete, navigate to results screen
    if (state.phase == HearingTestPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/test/results');
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(hearingTestProvider.notifier).pauseTest();
          context.push('/test/paused');
        }
      },
      child: Scaffold(
        appBar: EchoAppBar(
          title: 'Hearing Screening',
          showBackButton: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.p8),
              child: EchoButton(
                label: 'Pause test',
                variant: EchoButtonVariant.ghost,
                icon: Icons.pause,
                onPressed: () {
                  ref.read(hearingTestProvider.notifier).pauseTest();
                  context.push('/test/paused');
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: state.phase == HearingTestPhase.earInterstitial
              ? _EarInterstitialView(onContinue: () {
                  ref.read(hearingTestProvider.notifier).startRightEar();
                })
              : _ScreeningProgressView(state: state),
        ),
      ),
    );
  }
}

class _EarInterstitialView extends StatelessWidget {
  final VoidCallback onContinue;

  const _EarInterstitialView({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.headphones,
              size: 64.0,
              color: AppColors.blue500,
            ),
            const SizedBox(height: AppSpacing.p16),
            const EchoText(
              'Left Ear Screening Complete',
              variant: EchoTextStyleVariant.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.p12),
            const EchoText(
              'Please reposition your headphones or adjust fit to ensure a comfortable seal for your right ear.',
              variant: EchoTextStyleVariant.bodyLarge,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.p32),
            EchoButton(
              label: 'Continue to Right Ear',
              icon: Icons.arrow_forward,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreeningProgressView extends ConsumerWidget {
  final HearingTestState state;

  const _ScreeningProgressView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(hearingTestProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tag Row wrapped in Wrap for 200% text scale safety
          Wrap(
            spacing: AppSpacing.p8,
            runSpacing: AppSpacing.p8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p12,
                  vertical: AppSpacing.p6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.borderFunctional),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hearing,
                      size: 16.0,
                      color: AppColors.blue500,
                    ),
                    const SizedBox(width: AppSpacing.p6),
                    EchoText(
                      state.currentEar.label,
                      variant: EchoTextStyleVariant.labelMedium,
                      color: AppColors.blue500,
                    ),
                  ],
                ),
              ),
              const SampleDataTag(),
            ],
          ),
          const SizedBox(height: AppSpacing.p16),

          // 2. Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8.0,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue400),
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          EchoText(
            'Progress: ${(state.progress * 100).toInt()}%',
            variant: EchoTextStyleVariant.caption,
            textAlign: TextAlign.end,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.p24),

          // 3. Central Stimulus Card
          EchoCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24),
              child: Column(
                children: [
                  Container(
                    width: 96.0,
                    height: 96.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blue100,
                      border: Border.all(
                        color: AppColors.blue400,
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      size: 48.0,
                      color: AppColors.blue500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p16),
                  EchoText(
                    '${state.currentFrequency} Hz',
                    variant: EchoTextStyleVariant.displayLarge,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  EchoText(
                    'Relative Sound Level ${state.currentLevel} of 13',
                    variant: EchoTextStyleVariant.titleMedium,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.p32),

          // 4. Tone Feedback Actions
          EchoButton(
            label: 'I Hear It',
            icon: Icons.volume_up,
            onPressed: () => notifier.recordResponse(),
          ),
          const SizedBox(height: AppSpacing.p12),
          EchoButton(
            label: "Can't Hear It",
            variant: EchoButtonVariant.secondary,
            icon: Icons.volume_off,
            onPressed: () => notifier.recordNoResponse(),
          ),
        ],
      ),
    );
  }
}
