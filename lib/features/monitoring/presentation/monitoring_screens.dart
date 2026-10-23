import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Sound Monitoring',
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
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: EchoText('Live Sound Monitor', variant: EchoTextStyleVariant.titleMedium),
                        ),
                        SizedBox(width: AppSpacing.p8),
                        SampleDataTag(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    Row(
                      children: [
                        const Icon(Icons.mic, color: AppColors.blue500, size: 36.0),
                        const SizedBox(width: AppSpacing.p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              EchoText('Moderate Level', variant: EchoTextStyleVariant.displayLarge, color: AppColors.blue500),
                              EchoText('Comfortable ambient environment', variant: EchoTextStyleVariant.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              EchoButton(
                label: 'View Exposure History',
                icon: Icons.history,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/monitoring/history'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Exposure Details',
                icon: Icons.analytics_outlined,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/monitoring/exposure'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Monitoring Settings',
                icon: Icons.settings_outlined,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/monitoring/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonitoringHistoryScreen extends StatefulWidget {
  const MonitoringHistoryScreen({super.key});

  @override
  State<MonitoringHistoryScreen> createState() => _MonitoringHistoryScreenState();
}

class _MonitoringHistoryScreenState extends State<MonitoringHistoryScreen> {
  int _selectedSegment = 0; // 0: Day, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Monitoring History',
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.p8),
            child: Center(child: SampleDataTag()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Control: Day / Week / Month
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Day')),
                  ButtonSegment(value: 1, label: Text('Week')),
                  ButtonSegment(value: 2, label: Text('Month')),
                ],
                selected: {_selectedSegment},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedSegment = newSelection.first);
                },
              ),
              const SizedBox(height: AppSpacing.p24),
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EchoText('Historical Sound Levels', variant: EchoTextStyleVariant.titleMedium),
                        SampleDataTag(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p12),
                    EchoText(
                      'Average daily exposure maintained within recommended safety ranges.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExposureDetailScreen extends StatelessWidget {
  const ExposureDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Exposure Details', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Sound Dose Calculation', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText(
                  'Calculated using acoustic guidelines for personal audio monitoring.',
                  variant: EchoTextStyleVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MonitoringSettingsScreen extends StatelessWidget {
  const MonitoringSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Monitoring Settings', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Threshold Alerts', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText(
                  'Configure sound dose warnings and ambient noise sensitivity.',
                  variant: EchoTextStyleVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
