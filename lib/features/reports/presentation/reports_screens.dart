import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_segmented_control.dart';
import '../../../core/widgets/primitives/echo_stat_tile.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

/// Tab 3: Listening Reports Screen matching Board 1 Screen 14.
/// Features multi-period segmented control, summary cards, dual stat tiles,
/// daily duration distribution bar chart, and acoustic range breakdowns.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

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
              // 1. Period Segmented Control (Daily, Weekly, Monthly)
              EchoSegmentedControl<String>(
                options: const [
                  EchoSegmentOption(value: 'Daily', label: 'Daily', icon: Icons.today),
                  EchoSegmentOption(value: 'Weekly', label: 'Weekly', icon: Icons.view_week),
                  EchoSegmentOption(value: 'Monthly', label: 'Monthly', icon: Icons.calendar_month),
                ],
                selectedValue: _selectedPeriod,
                onChanged: (val) => setState(() => _selectedPeriod = val),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. Summary Highlight Card
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.p8,
                      runSpacing: AppSpacing.p4,
                      children: [
                        EchoText(
                          '$_selectedPeriod Summary',
                          variant: EchoTextStyleVariant.titleMedium,
                        ),
                        const SampleDataTag(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    const EchoText(
                      'Your listening habits remained 100% within recommended sound limits during this period.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 3. Dual Stat Tiles with responsive LayoutBuilder
              LayoutBuilder(
                builder: (context, constraints) {
                  final tileA = EchoStatTile(
                    icon: Icons.headphones_outlined,
                    value: _selectedPeriod == 'Daily' ? '2h 15m' : '1h 45m',
                    label: _selectedPeriod == 'Daily' ? 'Today Exposure' : 'Daily Avg Exposure',
                    badgeText: 'Optimal',
                  );
                  final tileB = EchoStatTile(
                    icon: Icons.calendar_today_outlined,
                    value: _selectedPeriod == 'Monthly' ? '54h 20m' : '12h 15m',
                    label: _selectedPeriod == 'Monthly' ? 'Monthly Total' : 'Weekly Total',
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

              // 4. Daily Duration Distribution Card
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.p8,
                      runSpacing: AppSpacing.p4,
                      children: [
                        EchoText('Listening Duration Distribution', variant: EchoTextStyleVariant.labelBold),
                        EchoText('7-Day Overview', variant: EchoTextStyleVariant.caption),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p16),
                    _WeeklyBarChart(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 5. Sound Level Exposure Breakdown Card
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.p8,
                      runSpacing: AppSpacing.p4,
                      children: [
                        EchoText('Acoustic Range Breakdown', variant: EchoTextStyleVariant.labelBold),
                        SampleDataTag(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.p16),
                    _RangeBreakdownRow(
                      label: 'Quiet (< Level 2)',
                      percentageText: '65%',
                      ratio: 0.65,
                      color: AppColors.blue500,
                    ),
                    SizedBox(height: AppSpacing.p12),
                    _RangeBreakdownRow(
                      label: 'Moderate (Level 2–4)',
                      percentageText: '30%',
                      ratio: 0.30,
                      color: AppColors.blue400,
                    ),
                    SizedBox(height: AppSpacing.p12),
                    _RangeBreakdownRow(
                      label: 'High (Level 5+)',
                      percentageText: '5%',
                      ratio: 0.05,
                      color: AppColors.blue200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 6. Navigation to Sub-feature Screens
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

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart();

  static const _days = [
    ('Mon', 1.8, 0.6),
    ('Tue', 2.4, 0.8),
    ('Wed', 1.5, 0.5),
    ('Thu', 2.1, 0.7),
    ('Fri', 2.8, 0.95),
    ('Sat', 1.2, 0.4),
    ('Sun', 0.9, 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.0,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _days.map((item) {
            final day = item.$1;
            final hours = item.$2;
            final ratio = item.$3;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p6),
              child: Semantics(
                label: '$day: ${hours}h listening',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 22.0,
                      height: 80.0 * ratio,
                      decoration: BoxDecoration(
                        color: AppColors.blue500,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p6),
                    Text(
                      day,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RangeBreakdownRow extends StatelessWidget {
  final String label;
  final String percentageText;
  final double ratio;
  final Color color;

  const _RangeBreakdownRow({
    required this.label,
    required this.percentageText,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: EchoText(label, variant: EchoTextStyleVariant.caption),
            ),
            const SizedBox(width: AppSpacing.p8),
            EchoText(percentageText, variant: EchoTextStyleVariant.captionBold),
          ],
        ),
        const SizedBox(height: AppSpacing.p6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8.0,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
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
