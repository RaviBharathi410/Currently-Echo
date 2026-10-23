import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_radii.dart';
import 'core/widgets/primitives/echo_text.dart';
import 'core/widgets/primitives/echo_button.dart';
import 'core/widgets/primitives/echo_card.dart';
import 'core/widgets/navigation/echo_app_bar.dart';
import 'core/widgets/navigation/echo_bottom_nav.dart';
import 'core/widgets/domain/sample_data_tag.dart';

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
  int _tapCount = 0;

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
              EchoCard(
                padding: const EdgeInsets.all(AppSpacing.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EchoText(
                      'Text Scale Simulation',
                      variant: EchoTextStyleVariant.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Wrap(
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. Buttons Section
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EchoText('EchoButton Variants', variant: EchoTextStyleVariant.heading),
                    const SizedBox(height: AppSpacing.p12),
                    Wrap(
                      spacing: AppSpacing.p8,
                      runSpacing: AppSpacing.p8,
                      children: [
                        EchoButton(
                          label: 'Primary CTA',
                          icon: Icons.check,
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 3. Status & Error State Component (Icon + Label + Tonal Treatment, Zero Red)
              EchoCard(
                semanticLabel: 'Status notification: Hearing test session interrupted. Tap to resume.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EchoText('Status & Error Treatment', variant: EchoTextStyleVariant.heading),
                    const SizedBox(height: AppSpacing.p8),
                    const EchoText(
                      'All states use Icon + Label + Tonal blue/border styling. Zero red hues permitted.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Container(
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 4. Interactive Card Section
              EchoCard(
                onTap: () => setState(() => _tapCount++),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p12),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: const Icon(Icons.touch_app, color: AppColors.blue500),
                    ),
                    const SizedBox(width: AppSpacing.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EchoText('Interactive EchoCard', variant: EchoTextStyleVariant.labelLarge),
                          EchoText('Tapped $_tapCount times', variant: EchoTextStyleVariant.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 5. Typography Scale
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EchoText('Typography Scale (DM Sans)', variant: EchoTextStyleVariant.heading),
                    SizedBox(height: AppSpacing.p8),
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
        items: const [
          EchoNavItem(icon: Icons.hearing, label: 'Test', fullLabel: 'Hearing Test'),
          EchoNavItem(icon: Icons.dashboard, label: 'Home', fullLabel: 'Home Dashboard'),
          EchoNavItem(icon: Icons.graphic_eq, label: 'Monitor', fullLabel: 'Sound Exposure Monitoring'),
          EchoNavItem(icon: Icons.insert_chart_outlined, label: 'Reports', fullLabel: 'Weekly Reports'),
          EchoNavItem(icon: Icons.person_outline, label: 'Profile', fullLabel: 'Profile & Settings'),
        ],
      ),
    );
  }
}
