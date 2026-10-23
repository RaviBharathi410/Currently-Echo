import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Listening Reports',
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
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EchoText('Weekly Summary', variant: EchoTextStyleVariant.titleMedium),
                        SampleDataTag(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p12),
                    EchoText(
                      'Your listening habits remained 100% within recommended sound limits this week.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              EchoButton(
                label: 'Weekly Report',
                icon: Icons.calendar_view_week,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/reports/weekly'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Exposure Trends',
                icon: Icons.show_chart,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/reports/exposure'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Insights & Tips',
                icon: Icons.lightbulb_outline,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/reports/insights'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Historical Data',
                icon: Icons.history,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/reports/historical'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsWeeklyScreen extends StatelessWidget {
  const ReportsWeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Weekly Report', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Weekly Listening Breakdown', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Daily average: 2.4 hours in moderate listening environments.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsExposureScreen extends StatelessWidget {
  const ReportsExposureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Exposure Trends', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('30-Day Exposure Trend', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Zero dangerous sound spikes recorded.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsInsightsScreen extends StatelessWidget {
  const ReportsInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Listening Insights', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Protecting Your Ears', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Taking 10-minute quiet breaks every hour reduces fatigue.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsHistoricalScreen extends StatelessWidget {
  const ReportsHistoricalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Historical Reports', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Archived Monthly Summaries', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('View and compare previous months of listening records.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
