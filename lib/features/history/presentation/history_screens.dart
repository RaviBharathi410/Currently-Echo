import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

class HearingHistoryScreen extends StatelessWidget {
  const HearingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Screening History',
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
                        EchoText('Previous Screenings', variant: EchoTextStyleVariant.titleMedium),
                        SampleDataTag(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p12),
                    EchoText(
                      'Track preliminary tone response estimates over time.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              EchoButton(
                label: 'Compare Screenings',
                icon: Icons.compare_arrows,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history/compare'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Screening Reminders',
                icon: Icons.alarm,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history/reminders'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'View Latest Record (Sample #1)',
                icon: Icons.description_outlined,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history/test-101'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestComparisonScreen extends StatelessWidget {
  const TestComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Compare Screenings', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Response Comparison', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Compare tone responses between October and September.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestRemindersScreen extends StatelessWidget {
  const TestRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Screening Reminders', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Reminder Frequency', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Monthly recurring prompt active.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestDetailScreen extends StatelessWidget {
  final String testId;

  const TestDetailScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EchoAppBar(title: 'Test Record $testId', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Record Identifier: $testId', variant: EchoTextStyleVariant.titleMedium),
                const SizedBox(height: AppSpacing.p8),
                const EchoText('Detailed frequency responses for Left and Right ear.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
