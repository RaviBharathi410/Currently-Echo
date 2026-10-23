import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

class AudioPersonalizationScreen extends StatelessWidget {
  const AudioPersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Audio Personalization',
        showBackButton: true,
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
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EchoText('Audio Clarity Tuning', variant: EchoTextStyleVariant.titleMedium),
                        SampleDataTag(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p12),
                    EchoText(
                      'Compensate personal audio output using your preliminary sound response estimates.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              EchoButton(
                label: 'Custom Equalizer',
                icon: Icons.tune,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/personalization/equalizer'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Speech Enhancement',
                icon: Icons.record_voice_over,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/personalization/enhancement'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Saved Audio Profiles',
                icon: Icons.bookmark_border,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/personalization/profiles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Custom Equalizer', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('5-Band Equalizer', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Tune low, mid, and high frequencies for comfortable speech clarity.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HearingEnhancementScreen extends StatelessWidget {
  const HearingEnhancementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Speech Enhancement', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Dialogue Clarity Mode', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Boost consonant frequencies (2000–4000 Hz) for clearer podcast and video speech.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SavedProfilesScreen extends StatelessWidget {
  const SavedProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Saved Profiles', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Preset Profiles', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Presets for: Commute, Quiet Room, Music, and Voice Calls.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
