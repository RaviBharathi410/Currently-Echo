import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_radii.dart';
import 'core/widgets/primitives/echo_text.dart';
import 'core/widgets/primitives/echo_button.dart';
import 'core/widgets/navigation/echo_app_bar.dart';
import 'core/widgets/navigation/echo_bottom_nav.dart';
import 'core/widgets/domain/sample_data_tag.dart';
import 'core/widgets/domain/echo_headphone_hero.dart';
import 'core/widgets/domain/echo_wave_backdrop.dart';
import 'core/widgets/domain/echo_glow_rings.dart';
import 'core/widgets/domain/echo_check_circle_hero.dart';
import 'core/widgets/domain/echo_ring_gauge.dart';
import 'core/widgets/primitives/echo_segmented_control.dart';
import 'core/widgets/primitives/echo_feature_tile.dart';
import 'core/widgets/primitives/echo_section_card.dart';
import 'core/widgets/primitives/echo_filter_chip.dart';
import 'core/widgets/primitives/echo_stat_tile.dart';
import 'core/widgets/navigation/echo_setting_row.dart';

import 'core/widgets/layout/echo_responsive_frame.dart';
import 'core/widgets/layout/echo_backdrop.dart';
import 'core/widgets/splash/echo_splash_gate.dart';

import 'app/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: EchoApp()));
}

class EchoApp extends ConsumerStatefulWidget {
  final double initialTextScale;
  final bool showGallery;
  final bool enableBackdropDrift;
  final bool disableSplash;
  final Future<void>? initializationFuture;

  const EchoApp({
    super.key,
    this.initialTextScale = 1.0,
    this.showGallery = false,
    this.enableBackdropDrift = false,
    this.disableSplash = false,
    this.initializationFuture,
  });

  @override
  ConsumerState<EchoApp> createState() => _EchoAppState();
}

class _EchoAppState extends ConsumerState<EchoApp> {
  late double _textScale;

  @override
  void initState() {
    super.initState();
    _textScale = widget.initialTextScale;
  }

  void _setTextScale(double scale) {
    setState(() => _textScale = scale);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showGallery) {
      return MaterialApp(
        title: 'ECHO Component Gallery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(_textScale),
            ),
            child: child!,
          );
        },
        home: ComponentGalleryScreen(
          currentScale: _textScale,
          onScaleChanged: _setTextScale,
        ),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ECHO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return EchoResponsiveFrame(
          child: EchoSplashGate(
            disableOverlay: widget.disableSplash,
            initializationFuture: widget.initializationFuture,
            backdrop: EchoBackdrop(enableDrift: widget.enableBackdropDrift),
            child: child,
          ),
        );
      },
    );
  }
}

class ComponentGalleryScreen extends StatefulWidget {
  final double currentScale;
  final ValueChanged<double> onScaleChanged;

  const ComponentGalleryScreen({
    super.key,
    required this.currentScale,
    required this.onScaleChanged,
  });

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  int _navIndex = 1;
  String _selectedSegment = 'Daily';
  String _selectedChip = 'Routine Check';
  bool _switchVal = true;
  EchoEarTarget _activeEar = EchoEarTarget.left;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Component Gallery',
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
              // 1. Text Scale Switcher Header
              EchoSectionCard(
                title: 'Text Scale Simulation',
                subtitle: 'Verify 200% accessibility compliance',
                child: Wrap(
                  spacing: AppSpacing.p8,
                  runSpacing: AppSpacing.p8,
                  children: [
                    EchoButton(
                      label: '1.0x Scale',
                      variant: widget.currentScale == 1.0
                          ? EchoButtonVariant.primary
                          : EchoButtonVariant.secondary,
                      onPressed: () => widget.onScaleChanged(1.0),
                    ),
                    EchoButton(
                      label: '2.0x Scale (A11y)',
                      variant: widget.currentScale == 2.0
                          ? EchoButtonVariant.primary
                          : EchoButtonVariant.secondary,
                      onPressed: () => widget.onScaleChanged(2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. EchoHeadphoneHero & EchoGlowRings
              EchoSectionCard(
                title: 'EchoHeadphoneHero & EchoGlowRings',
                subtitle: 'Programmatic illustrations (No PNG assets)',
                trailing: TextButton(
                  onPressed: () {
                    setState(() {
                      if (_activeEar == EchoEarTarget.left) {
                        _activeEar = EchoEarTarget.right;
                      } else if (_activeEar == EchoEarTarget.right) {
                        _activeEar = EchoEarTarget.both;
                      } else if (_activeEar == EchoEarTarget.both) {
                        _activeEar = EchoEarTarget.none;
                      } else {
                        _activeEar = EchoEarTarget.left;
                      }
                    });
                  },
                  child: Text('Toggle Ear (${_activeEar.name})'),
                ),
                child: Center(
                  child: EchoGlowRings(
                    size: 210.0,
                    isPulsing: true,
                    child: EchoHeadphoneHero(
                      size: 160.0,
                      activeEar: _activeEar,
                      showBadges: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 3. EchoCheckCircleHero (With Tonal Blue Confetti Dots)
              EchoSectionCard(
                title: 'EchoCheckCircleHero',
                subtitle: 'Success hero with tonal blue confetti dots (Zero off-palette)',
                child: const Center(
                  child: EchoCheckCircleHero(
                    size: 130.0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 4. EchoRingGauge & Sound Wave Backdrop
              EchoSectionCard(
                title: 'EchoRingGauge & EchoWaveBackdrop',
                subtitle: 'Sound Monitoring display (Relative levels, non-clinical)',
                child: Column(
                  children: [
                    const EchoRingGauge(
                      value: 0.65,
                      size: 190.0,
                      levelLabel: 'Level 3 of 5',
                      statusLabel: 'Moderate, sample',
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    ClipRRect(
                      borderRadius: AppRadii.roundedMd,
                      child: Container(
                        color: AppColors.surfaceSubtle,
                        child: const EchoWaveBackdrop(
                          height: 80.0,
                          child: Center(
                            child: EchoText(
                              'Ambient Acoustic Waves',
                              variant: EchoTextStyleVariant.captionBold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 5. EchoSegmentedControl & EchoFilterChips
              EchoSectionCard(
                title: 'EchoSegmentedControl & Filter Chips',
                subtitle: 'Selectable pill components with 48dp touch targets',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EchoSegmentedControl<String>(
                      options: const [
                        EchoSegmentOption(value: 'Daily', label: 'Daily', icon: Icons.calendar_today_outlined),
                        EchoSegmentOption(value: 'Weekly', label: 'Weekly', icon: Icons.view_week_outlined),
                        EchoSegmentOption(value: 'Monthly', label: 'Monthly', icon: Icons.calendar_month_outlined),
                      ],
                      selectedValue: _selectedSegment,
                      onChanged: (val) => setState(() => _selectedSegment = val),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Wrap(
                      spacing: AppSpacing.p8,
                      runSpacing: AppSpacing.p8,
                      children: [
                        'All',
                        'Routine Check',
                        'Detailed',
                        'Baseline',
                      ].map((chip) {
                        return EchoFilterChip(
                          label: chip,
                          isSelected: _selectedChip == chip,
                          onTap: () => setState(() => _selectedChip = chip),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 6. EchoStatTile (Dual Metric Grid)
              const EchoSectionCard(
                title: 'EchoStatTile',
                subtitle: 'Metric cards matching Dashboard & Reports',
                child: Row(
                  children: [
                    Expanded(
                      child: EchoStatTile(
                        icon: Icons.timer_outlined,
                        value: '2h 15m',
                        label: 'Daily Exposure',
                        badgeText: 'Optimal',
                      ),
                    ),
                    SizedBox(width: AppSpacing.p12),
                    Expanded(
                      child: EchoStatTile(
                        icon: Icons.check_circle_outline,
                        value: '94%',
                        label: 'Consistency',
                        badgeText: 'Stable',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 7. EchoFeatureTile
              EchoSectionCard(
                title: 'EchoFeatureTile',
                subtitle: 'Feature cards with light-blue icon tile',
                child: Column(
                  children: [
                    EchoFeatureTile(
                      icon: Icons.mic_rounded,
                      title: 'Microphone Access',
                      subtitle: 'Calibrate environmental sound monitoring with precision.',
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    EchoFeatureTile(
                      icon: Icons.headphones_rounded,
                      title: 'Headphones Setup',
                      subtitle: 'Verify channel isolation before screening.',
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 8. EchoSettingRow
              EchoSectionCard(
                title: 'EchoSettingRow',
                subtitle: 'Standardized settings rows matching Profile',
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    EchoSettingRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Daily Reminders',
                      subtitle: 'Hearing check prompt at 9:00 AM',
                      trailing: Switch(
                        value: _switchVal,
                        onChanged: (v) => setState(() => _switchVal = v),
                        activeThumbColor: AppColors.blue500,
                      ),
                    ),
                    EchoSettingRow(
                      icon: Icons.volume_up_outlined,
                      title: 'Sound Calibration',
                      subtitle: 'Standard tone frequency range',
                      onTap: () {},
                    ),
                    EchoSettingRow(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy & Disclaimers',
                      subtitle: 'Non-diagnostic screening notice',
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 9. Buttons Section
              EchoSectionCard(
                title: 'EchoButton Variants',
                subtitle: 'Primary, Secondary, Ghost, Loading, Disabled',
                child: Wrap(
                  spacing: AppSpacing.p8,
                  runSpacing: AppSpacing.p8,
                  children: [
                    EchoButton(
                      label: 'Primary CTA',
                      icon: Icons.check_rounded,
                      onPressed: () {},
                    ),
                    EchoButton(
                      label: 'Secondary',
                      variant: EchoButtonVariant.secondary,
                      onPressed: () {},
                    ),
                    EchoButton(
                      label: 'Ghost Action',
                      variant: EchoButtonVariant.ghost,
                      onPressed: () {},
                    ),
                    const EchoButton(
                      label: 'Loading',
                      isLoading: true,
                      onPressed: null,
                    ),
                    const EchoButton(
                      label: 'Disabled',
                      onPressed: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 10. Status & Error State Treatment (Zero Red)
              EchoSectionCard(
                title: 'Status & Error Treatment',
                subtitle: 'Icon + Label + Tonal blue styling (Zero red hues)',
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.p12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(color: AppColors.blue400, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.blue500, size: 24.0),
                      SizedBox(width: AppSpacing.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EchoText(
                              'Test Paused',
                              variant: EchoTextStyleVariant.labelLarge,
                              color: AppColors.blue500,
                            ),
                            SizedBox(height: AppSpacing.p4),
                            EchoText(
                              'Headphones disconnected. Plug in to resume screening.',
                              variant: EchoTextStyleVariant.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 11. Typography Scale (DM Sans)
              const EchoSectionCard(
                title: 'Typography Scale (DM Sans)',
                subtitle: 'Strict single font family design system',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EchoText('1000 Hz', variant: EchoTextStyleVariant.frequencyDisplay),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Display Large 32sp', variant: EchoTextStyleVariant.displayLarge),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Title Large 24sp', variant: EchoTextStyleVariant.titleLarge),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Title Medium 20sp', variant: EchoTextStyleVariant.titleMedium),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Heading 18sp', variant: EchoTextStyleVariant.heading),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Body Large 16sp', variant: EchoTextStyleVariant.bodyLarge),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Body Medium 14sp (Minimum body floor)', variant: EchoTextStyleVariant.bodyMedium),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Label Large 14sp Medium', variant: EchoTextStyleVariant.labelLarge),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Label Medium 12sp Medium', variant: EchoTextStyleVariant.labelMedium),
                    SizedBox(height: AppSpacing.p4),
                    EchoText('Caption 12sp (Minimum caption floor)', variant: EchoTextStyleVariant.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EchoBottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}
