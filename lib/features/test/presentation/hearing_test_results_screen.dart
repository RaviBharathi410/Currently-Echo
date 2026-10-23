import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';
import '../../onboarding/application/onboarding_provider.dart';
import '../application/hearing_test_notifier.dart';
import '../domain/models/hearing_threshold_result.dart';

class HearingTestResultsScreen extends ConsumerWidget {
  const HearingTestResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hearingTestProvider);

    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Screening Results',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.p8),
            child: Center(child: SampleDataTag()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overview Card
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: EchoText(
                            'Tone Response Pattern',
                            variant: EchoTextStyleVariant.titleMedium,
                          ),
                        ),
                        SampleDataTag(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    const EchoText(
                      'Estimated relative frequency response (Level 1–13)',
                      variant: EchoTextStyleVariant.caption,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.blue500, size: 20.0),
                          SizedBox(width: AppSpacing.p8),
                          Expanded(
                            child: EchoText(
                              'Sample data: Indicative sound response profile for audio equalization.',
                              variant: EchoTextStyleVariant.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. Left Ear Results Card
              _EarResultsCard(
                earLabel: 'Left Ear',
                results: state.leftEarResults,
              ),
              const SizedBox(height: AppSpacing.p16),

              // 3. Right Ear Results Card
              _EarResultsCard(
                earLabel: 'Right Ear',
                results: state.rightEarResults,
              ),
              const SizedBox(height: AppSpacing.p24),

              // 4. Action Button
              EchoButton(
                label: 'Continue to Dashboard',
                icon: Icons.check,
                onPressed: () {
                  ref.read(onboardingProvider.notifier).completeOnboarding();
                  ref.read(hearingTestProvider.notifier).reset();
                  context.go('/dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarResultsCard extends StatelessWidget {
  final String earLabel;
  final List<HearingThresholdResult> results;

  const _EarResultsCard({
    required this.earLabel,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return EchoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hearing, size: 20.0, color: AppColors.blue500),
              const SizedBox(width: AppSpacing.p8),
              EchoText(earLabel, variant: EchoTextStyleVariant.heading),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          if (results.isEmpty)
            const EchoText(
              'No response recorded yet (Sample)',
              variant: EchoTextStyleVariant.caption,
              color: AppColors.textSecondary,
            )
          else
            ...results.map((res) {
              final statusText = res.isDetected
                  ? 'Detected at Level ${res.level}'
                  : 'Inaudible at limit (Level 13)';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    EchoText(
                      '${res.frequencyHz} Hz',
                      variant: EchoTextStyleVariant.bodyMedium,
                    ),
                    EchoText(
                      statusText,
                      variant: EchoTextStyleVariant.labelMedium,
                      color: res.isDetected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
