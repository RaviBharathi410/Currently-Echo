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
import '../application/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: const EchoAppBar(
        title: 'ECHO Dashboard',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.p8),
            child: Center(child: SampleDataTag()),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (dashboardState.status) {
          DashboardStatus.loading => const _DashboardLoadingView(),
          DashboardStatus.error => _DashboardErrorView(
              errorMessage: dashboardState.errorMessage ?? 'Unable to load dashboard data.',
              onRetry: () => ref.read(dashboardProvider.notifier).retry(),
            ),
          DashboardStatus.empty => const _DashboardEmptyView(),
          DashboardStatus.loaded => _DashboardLoadedView(data: dashboardState.data ?? const DashboardData()),
        },
      ),
    );
  }
}

class _DashboardLoadingView extends StatelessWidget {
  const _DashboardLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue400),
              strokeWidth: 3.0,
            ),
            SizedBox(height: AppSpacing.p16),
            EchoText(
              'Loading illustrative estimates...',
              variant: EchoTextStyleVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _DashboardErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: EchoCard(
          semanticLabel: 'Error: $errorMessage',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48.0,
                color: AppColors.blue500, // Tonal error: strictly blue500
              ),
              const SizedBox(height: AppSpacing.p16),
              const EchoText(
                'Unable to Load Dashboard Data',
                variant: EchoTextStyleVariant.titleMedium,
                color: AppColors.blue500,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.p8),
              EchoText(
                errorMessage,
                variant: EchoTextStyleVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.p24),
              EchoButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardEmptyView extends StatelessWidget {
  const _DashboardEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: EchoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.hearing_outlined,
                size: 48.0,
                color: AppColors.blue500,
              ),
              const SizedBox(height: AppSpacing.p16),
              const EchoText(
                'No Listening Estimates Yet',
                variant: EchoTextStyleVariant.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.p8),
              const EchoText(
                'Connect your headphones or complete your initial preliminary sound check to generate illustrative listening estimates.',
                variant: EchoTextStyleVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.p24),
              EchoButton(
                label: 'Start Preliminary Screening',
                icon: Icons.play_arrow,
                onPressed: () => context.go('/test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadedView extends StatelessWidget {
  final DashboardData data;

  const _DashboardLoadedView({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Connected Device Status Banner (Generic, no brand/battery)
          EchoCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.p8),
                  decoration: BoxDecoration(
                    color: AppColors.blue100,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(
                    Icons.bluetooth_connected,
                    color: AppColors.blue500,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.p12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EchoText(
                        'Headphones Connected',
                        variant: EchoTextStyleVariant.labelBold,
                      ),
                      SizedBox(height: 2.0),
                      EchoText(
                        'Connected via Bluetooth • Audio Profile Active',
                        variant: EchoTextStyleVariant.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p16),

          // 2. Daily Sound Exposure Card (Illustrative Estimate - Plain Durations & Relative Levels)
          EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  spacing: AppSpacing.p8,
                  runSpacing: AppSpacing.p4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EchoText(
                      'Daily Sound Exposure',
                      variant: EchoTextStyleVariant.cardTitle,
                    ),
                    SampleDataTag(),
                  ],
                ),
                const SizedBox(height: AppSpacing.p4),
                const EchoText(
                  'Illustrative estimate based on personal audio monitoring guidelines',
                  variant: EchoTextStyleVariant.caption,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.p16),

                // Metrics Wrap (Plain durations and relative exposure levels)
                Wrap(
                  spacing: AppSpacing.p16,
                  runSpacing: AppSpacing.p12,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _MetricColumn(
                      label: "Today's Listening",
                      value: data.listeningDurationText,
                    ),
                    _MetricColumn(
                      label: 'Ambient Exposure',
                      value: data.ambientLevelLabel,
                    ),
                    _MetricColumn(
                      label: 'Current Session',
                      value: data.currentSessionDurationText,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),

                // Relative Exposure Indicator Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: const LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 8.0,
                    backgroundColor: AppColors.surfaceSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue400),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p16),

          // 3. Preliminary Tone Response Profile Card
          EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.p8,
                  runSpacing: AppSpacing.p4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const EchoText(
                      'Tone Response Profile',
                      variant: EchoTextStyleVariant.cardTitle,
                    ),
                    const SampleDataTag(),
                  ],
                ),
                const SizedBox(height: AppSpacing.p4),
                EchoText(
                  'Last checked: ${data.lastScreeningDateText}',
                  variant: EchoTextStyleVariant.caption,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.p12),
                EchoText(
                  data.screeningResponseProfileSummary,
                  variant: EchoTextStyleVariant.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.p16),
                EchoButton(
                  label: 'Check Response Again',
                  icon: Icons.refresh,
                  variant: EchoButtonVariant.secondary,
                  onPressed: () => context.go('/test'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p16),

          // 4. Quick Access Actions (Wrap for text-scale safety)
          const EchoText('Quick Access', variant: EchoTextStyleVariant.sectionHeader),
          const SizedBox(height: AppSpacing.p12),
          Wrap(
            spacing: AppSpacing.p12,
            runSpacing: AppSpacing.p12,
            children: [
              EchoButton(
                label: 'History',
                icon: Icons.history,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history'),
              ),
              EchoButton(
                label: 'Equalizer',
                icon: Icons.tune,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/personalization/equalizer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;

  const _MetricColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EchoText(
          value,
          variant: EchoTextStyleVariant.statDisplay,
        ),
        const SizedBox(height: 4.0),
        EchoText(
          label,
          variant: EchoTextStyleVariant.statLabel,
        ),
      ],
    );
  }
}
