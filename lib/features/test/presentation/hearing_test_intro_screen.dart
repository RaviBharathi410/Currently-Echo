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
import '../../../core/widgets/domain/echo_glow_rings.dart';
import '../../../core/widgets/domain/echo_headphone_hero.dart';
import '../application/hearing_test_notifier.dart';
import '../domain/models/hearing_threshold_result.dart';
import 'widgets/hearing_readiness_checklist.dart';

class HearingTestIntroScreen extends ConsumerStatefulWidget {
  final Widget? bottomNavigationBar;

  const HearingTestIntroScreen({
    super.key,
    this.bottomNavigationBar,
  });

  @override
  ConsumerState<HearingTestIntroScreen> createState() => _HearingTestIntroScreenState();
}

class _HearingTestIntroScreenState extends ConsumerState<HearingTestIntroScreen> {
  final Set<int> _checkedIndices = <int>{};

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(hearingTestProvider);
    final hasActiveSession = testState.phase == HearingTestPhase.inProgress ||
        testState.phase == HearingTestPhase.paused ||
        testState.phase == HearingTestPhase.earInterstitial;

    // Frequencies sorted in ascending order for display
    final sortedFrequencies = [...kScreeningFrequencies]..sort();
    final bool isReady = _checkedIndices.length == 3;

    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Hearing Screening',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.p8),
            child: Center(child: SampleDataTag()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Active Session Resume Banner (if mid-session)
                    if (hasActiveSession) ...[
                      EchoCard(
                        child: Row(
                          children: [
                            const Icon(Icons.pause_circle_outline, color: AppColors.blue500, size: 28.0),
                            const SizedBox(width: AppSpacing.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const EchoText('Active Screening Paused', variant: EchoTextStyleVariant.labelLarge),
                                  EchoText(
                                    'Screening session in progress • ${testState.currentEar.label}',
                                    variant: EchoTextStyleVariant.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p16),
                    ],

                    EchoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                              child: EchoGlowRings(
                                size: 160.0,
                                isPulsing: true,
                                child: const EchoHeadphoneHero(
                                  size: 130.0,
                                  showBadges: true,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.headphones,
                                color: AppColors.blue500,
                                size: 28.0,
                              ),
                              const SizedBox(width: AppSpacing.p12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const EchoText(
                                      'Preliminary Sound Screening',
                                      variant: EchoTextStyleVariant.cardTitle,
                                    ),
                                    const SizedBox(height: AppSpacing.p4),
                                    const EchoText(
                                      'Quick, non-clinical tone response check',
                                      variant: EchoTextStyleVariant.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.p16),
                          EchoText(
                            'This check presents a sequence of ${sortedFrequencies.length} test tones across speech frequencies (${sortedFrequencies.join(', ')} Hz) to estimate relative hearing response.',
                            variant: EchoTextStyleVariant.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.p12),
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
                                    'Indicative screening only. Not a medical or clinical diagnosis.',
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

                    // Interactive Readiness Checklist with Progress Ring
                    HearingReadinessChecklist(
                      checkedIndices: _checkedIndices,
                      onToggle: (index) {
                        setState(() {
                          if (_checkedIndices.contains(index)) {
                            _checkedIndices.remove(index);
                          } else {
                            _checkedIndices.add(index);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.p16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasActiveSession) ...[
                      // Resume & Restart remain ungated
                      EchoButton(
                        label: 'Resume Screening',
                        icon: Icons.play_arrow,
                        onPressed: () {
                          context.push(
                            testState.phase == HearingTestPhase.paused
                                ? '/test/paused'
                                : '/test/in-progress',
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.p8),
                      EchoButton(
                        label: 'Restart Fresh Screening',
                        variant: EchoButtonVariant.secondary,
                        icon: Icons.refresh,
                        onPressed: () {
                          ref.read(hearingTestProvider.notifier).startTest();
                          context.push('/test/in-progress');
                        },
                      ),
                    ] else ...[
                      // Start Screening is gated until all 3 checks are complete
                      EchoButton(
                        label: 'Start Screening',
                        icon: Icons.play_arrow,
                        onPressed: isReady
                            ? () {
                                ref.read(hearingTestProvider.notifier).startTest();
                                context.push('/test/in-progress');
                              }
                            : null,
                        semanticHint: !isReady ? 'Complete all 3 checks to begin' : null,
                      ),
                      if (!isReady) ...[
                        const SizedBox(height: AppSpacing.p8),
                        const EchoText(
                          'Complete all 3 checks to begin',
                          variant: EchoTextStyleVariant.caption,
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

