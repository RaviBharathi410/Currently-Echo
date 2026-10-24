import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/domain/echo_ring_gauge.dart';
import '../../../core/widgets/domain/echo_wave_backdrop.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_segmented_control.dart';
import '../../../core/widgets/primitives/echo_stat_tile.dart';
import '../../../core/widgets/primitives/echo_text.dart';

/// Screen 8: Sound Monitoring
/// Matches Board 1 Screen 8.
/// Integrates [EchoRingGauge], [EchoWaveBackdrop], [EchoSegmentedControl], and [EchoStatTile].
/// Strict non-negotiable rules: strictly zero 'dB' references, zero clinical claims,
/// and purely monochromatic Electric Royal Blue & white palette.
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  String _selectedTimeframe = 'Daily';

  @override
  Widget build(BuildContext context) {
    final isDaily = _selectedTimeframe == 'Daily';
    final gaugeValue = isDaily ? 0.60 : 0.45;
    final levelLabel = isDaily ? 'Level 3 of 5' : 'Level 2 of 5';

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
              // 1. Timeframe Segmented Control (Daily / Weekly)
              EchoSegmentedControl<String>(
                options: const [
                  EchoSegmentOption(value: 'Daily', label: 'Daily', icon: Icons.today),
                  EchoSegmentOption(value: 'Weekly', label: 'Weekly', icon: Icons.view_week),
                ],
                selectedValue: _selectedTimeframe,
                onChanged: (val) => setState(() => _selectedTimeframe = val),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. Central Gauge Card with Multi-layered Wave Backdrop
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: EchoText(
                            'Current Sound Exposure',
                            variant: EchoTextStyleVariant.cardTitle,
                          ),
                        ),
                        SampleDataTag(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    const EchoText(
                      'Illustrative acoustic exposure estimate based on ambient guidelines.',
                      variant: EchoTextStyleVariant.caption,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.p16),

                    // Centered Ring Gauge embedded in Wave Backdrop
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const EchoWaveBackdrop(height: 240.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                            child: EchoRingGauge(
                              value: gaugeValue,
                              size: 210.0,
                              levelLabel: levelLabel,
                              statusLabel: 'Moderate, sample',
                              centerIcon: Icons.graphic_eq_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 3. Dual Stat Tiles (Ambient vs Headphone) with responsive wrap for 200% accessibility scale
              LayoutBuilder(
                builder: (context, constraints) {
                  final tileA = EchoStatTile(
                    icon: Icons.mic_none_outlined,
                    value: isDaily ? 'Level 2' : 'Level 2',
                    label: 'Ambient Sound',
                    badgeText: 'Moderate',
                  );
                  final tileB = EchoStatTile(
                    icon: Icons.headphones_outlined,
                    value: isDaily ? '2h 15m' : '14h 40m',
                    label: 'Headset Exposure',
                    badgeText: 'In Range',
                  );

                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  if (constraints.maxWidth < 340 || textScale > 1.3) {
                    return Column(
                      children: [
                        tileA,
                        const SizedBox(height: AppSpacing.p12),
                        tileB,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: tileA),
                      const SizedBox(width: AppSpacing.p12),
                      Expanded(child: tileB),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.p16),

              // 4. Acoustic Guidance Summary Card
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.blue500, size: 24.0),
                        SizedBox(width: AppSpacing.p8),
                        Expanded(
                          child: EchoText('Acoustic Awareness Note', variant: EchoTextStyleVariant.labelBold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    const EchoText(
                      'Maintaining personal audio at moderate levels supports daily auditory comfort. Measurements represent simulated non-calibrated estimates.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 5. Navigation & Sub-feature Links
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
  String _selectedPeriod = 'Day';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EchoSegmentedControl<String>(
                options: const [
                  EchoSegmentOption(value: 'Day', label: 'Day'),
                  EchoSegmentOption(value: 'Week', label: 'Week'),
                  EchoSegmentOption(value: 'Month', label: 'Month'),
                ],
                selectedValue: _selectedPeriod,
                onChanged: (val) => setState(() => _selectedPeriod = val),
              ),
              const SizedBox(height: AppSpacing.p16),
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
