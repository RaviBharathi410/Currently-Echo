import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_checkbox.dart';
import '../../../core/widgets/primitives/echo_switch.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/primitives/echo_text_field.dart';
import '../../auth/application/auth_provider.dart';
import '../../test/application/hearing_test_notifier.dart';
import '../../test/domain/models/hearing_threshold_result.dart';
import '../../onboarding/application/onboarding_provider.dart';


// =============================================================================
// 1. WelcomeScreen (/welcome)
// =============================================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'ECHO',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.p16),
              Center(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: const BoxDecoration(
                    color: AppColors.blue100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.graphic_eq,
                    size: 44.0,
                    color: AppColors.blue500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              const EchoText(
                'Welcome to ECHO',
                variant: EchoTextStyleVariant.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.p8),
              const EchoText(
                'Personalized hearing clarity and daily listening monitoring.',
                variant: EchoTextStyleVariant.bodyLarge,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p32),

              // Value Proposition Cards
              const _ValuePropCard(
                icon: Icons.hearing,
                title: 'Preliminary Sound Screening',
                description: 'Fast, non-clinical tone response checks across key speech frequencies.',
              ),
              const SizedBox(height: AppSpacing.p12),
              const _ValuePropCard(
                icon: Icons.headphones,
                title: 'Acoustic Monitoring',
                description: 'Illustrative estimates of listening duration and ambient sound exposure.',
              ),
              const SizedBox(height: AppSpacing.p12),
              const _ValuePropCard(
                icon: Icons.tune,
                title: 'Sound Personalization',
                description: 'Customizable multi-band equalization tailored to your listening preferences.',
              ),
              const SizedBox(height: AppSpacing.p32),

              // Action Buttons
              EchoButton(
                label: 'Get Started',
                icon: Icons.arrow_forward,
                onPressed: () => context.go('/auth'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'I Already Have an Account',
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.go('/auth'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValuePropCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValuePropCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return EchoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.p8),
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: AppColors.blue500, size: 24.0),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText(title, variant: EchoTextStyleVariant.labelBold),
                const SizedBox(height: AppSpacing.p4),
                EchoText(
                  description,
                  variant: EchoTextStyleVariant.caption,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. AuthScreen (/auth)
// =============================================================================
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit(WidgetRef ref) {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? 'Please enter your email address'
          : null;
      _passwordError = _passwordController.text.trim().isEmpty
          ? 'Please enter your password'
          : null;
    });

    if (_emailError != null || _passwordError != null) return;

    final userName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Alex Parker';

    ref.read(authProvider.notifier).signIn(userName: userName);
    context.go('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          appBar: const EchoAppBar(title: 'Account', showBackButton: true),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EchoText(
                    isSignUp ? 'Create Your Account' : 'Welcome Back',
                    variant: EchoTextStyleVariant.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  EchoText(
                    isSignUp
                        ? 'Register to save your screening history and audio profiles.'
                        : 'Sign in to access your saved screening history.',
                    variant: EchoTextStyleVariant.bodyMedium,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.p20),

                  // Tab switcher
                  Row(
                    children: [
                      Expanded(
                        child: EchoButton(
                          label: 'Sign In',
                          variant: !isSignUp ? EchoButtonVariant.primary : EchoButtonVariant.secondary,
                          onPressed: () => setState(() => isSignUp = false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p12),
                      Expanded(
                        child: EchoButton(
                          label: 'Register',
                          variant: isSignUp ? EchoButtonVariant.primary : EchoButtonVariant.secondary,
                          onPressed: () => setState(() => isSignUp = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p24),

                  if (isSignUp) ...[
                    EchoTextField(
                      label: 'Full Name',
                      hintText: 'e.g. Alex Parker',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.blue500),
                    ),
                    const SizedBox(height: AppSpacing.p16),
                  ],

                  EchoTextField(
                    label: 'Email Address',
                    hintText: 'alex@example.com',
                    controller: _emailController,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.blue500),
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  EchoTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    controller: _passwordController,
                    errorText: _passwordError,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.blue500),
                  ),
                  const SizedBox(height: AppSpacing.p24),

                  EchoButton(
                    label: isSignUp ? 'Create Account' : 'Sign In',
                    icon: Icons.check,
                    onPressed: () => _submit(ref),
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  // Guest Bypass Button
                  EchoButton(
                    label: 'Continue as Guest',
                    variant: EchoButtonVariant.secondary,
                    icon: Icons.person_outline,
                    onPressed: () {
                      ref.read(authProvider.notifier).continueAsGuest();
                      context.go('/profile-setup');
                    },
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  const EchoText(
                    'Simulated authentication for UI demonstration. No real credentials are transmitted.',
                    variant: EchoTextStyleVariant.caption,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// 3. ProfileSetupScreen (/profile-setup)
// Scope: Name, Age / Age Range, Preferred Language.
// =============================================================================
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController(text: 'Alex Parker');
  String _selectedAgeRange = '18–35';
  String _selectedLanguage = 'English';

  final List<String> _ageRanges = const ['18–35', '36–50', '51–65', '65+'];
  final List<String> _languages = const ['English', 'Spanish', 'French', 'German'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Profile Setup', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EchoText('Your Profile', variant: EchoTextStyleVariant.titleLarge),
              const SizedBox(height: AppSpacing.p4),
              const EchoText(
                'Configure baseline details to personalize your audio experience.',
                variant: EchoTextStyleVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p24),

              // 1. Name Input
              EchoTextField(
                label: 'Preferred Name',
                hintText: 'Enter your name',
                controller: _nameController,
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.blue500),
              ),
              const SizedBox(height: AppSpacing.p24),

              // 2. Age Range Selection
              const EchoText('Age Range', variant: EchoTextStyleVariant.labelBold),
              const SizedBox(height: AppSpacing.p4),
              const EchoText(
                'Used for non-clinical demographic baseline context.',
                variant: EchoTextStyleVariant.caption,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p12),
              Wrap(
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p8,
                children: _ageRanges.map((range) {
                  final isSelected = _selectedAgeRange == range;
                  return ChoiceChip(
                    label: EchoText(
                      range,
                      variant: EchoTextStyleVariant.labelMedium,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.blue500,
                    backgroundColor: AppColors.surfaceSubtle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      side: BorderSide(
                        color: isSelected ? AppColors.blue500 : AppColors.border,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedAgeRange = range);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.p24),

              // 3. Preferred Language Selection
              const EchoText('Preferred Language', variant: EchoTextStyleVariant.labelBold),
              const SizedBox(height: AppSpacing.p4),
              const EchoText(
                'Interface language for audio instructions and screening prompts.',
                variant: EchoTextStyleVariant.caption,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p12),
              Wrap(
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p8,
                children: _languages.map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return ChoiceChip(
                    label: EchoText(
                      lang,
                      variant: EchoTextStyleVariant.labelMedium,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.blue500,
                    backgroundColor: AppColors.surfaceSubtle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      side: BorderSide(
                        color: isSelected ? AppColors.blue500 : AppColors.border,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedLanguage = lang);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.p32),

              EchoButton(
                label: 'Continue to Disclaimer',
                icon: Icons.arrow_forward,
                onPressed: () {
                  try {
                    ref.read(onboardingProvider.notifier).setProfile(
                      name: _nameController.text.trim(),
                      age: _selectedAgeRange,
                      language: _selectedLanguage,
                    );
                    ref.read(onboardingProvider.notifier).setStep(3);
                  } catch (_) {}
                  context.go('/disclaimer');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. DisclaimerScreen (/disclaimer)
// Scope Wording: "preliminary screening, not a substitute for professional audiological assessment"
// =============================================================================
class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool isAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Health Notice', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.blue500, size: 28.0),
                        SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: EchoText(
                            'Important Health Notice',
                            variant: EchoTextStyleVariant.cardTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    const EchoText(
                      'ECHO provides a preliminary screening, not a substitute for professional audiological assessment.',
                      variant: EchoTextStyleVariant.bodyLarge,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    const EchoText(
                      'This software application does not perform calibrated medical diagnosis or clinical audiometry. Sound response indicators, ambient exposure levels, and listening estimates are indicative only and intended for personal audio habit awareness.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    const EchoText(
                      'If you experience persistent ear discomfort, tinnitus, or sudden changes in hearing ability, consult a certified audiologist or physician.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),

              // Mandatory Checkbox Gate
              EchoCheckbox(
                value: isAcknowledged,
                onChanged: (val) => setState(() => isAcknowledged = val),
                label: const EchoText(
                  'I understand that ECHO provides a preliminary screening, not a substitute for professional audiological assessment.',
                  variant: EchoTextStyleVariant.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.p32),

              EchoButton(
                label: 'Accept & Continue',
                icon: Icons.check,
                onPressed: isAcknowledged
                    ? () {
                        try {
                          ref.read(onboardingProvider.notifier).acceptDisclaimer(true);
                          ref.read(onboardingProvider.notifier).setStep(4);
                        } catch (_) {}
                        context.go('/permissions');
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 5. PermissionsScreen (/permissions)
// Scope: Microphone, Notifications, Bluetooth. Copy: Simulated.
// =============================================================================
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool micEnabled = true;
  bool notifEnabled = true;
  bool bluetoothEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Permissions', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EchoText('System Permissions', variant: EchoTextStyleVariant.titleLarge),
              const SizedBox(height: AppSpacing.p4),
              const EchoText(
                'Simulated permissions for UI demonstration. No actual system permissions are requested.',
                variant: EchoTextStyleVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p24),

              // 1. Microphone Card
              _PermissionCard(
                icon: Icons.mic_none,
                title: 'Microphone Permission',
                subtitle: 'Simulated ambient sound level estimation.',
                value: micEnabled,
                onChanged: (val) => setState(() => micEnabled = val),
              ),
              const SizedBox(height: AppSpacing.p12),

              // 2. Notifications Card
              _PermissionCard(
                icon: Icons.notifications_none,
                title: 'Notifications Permission',
                subtitle: 'Simulated daily listening reminders and summary alerts.',
                value: notifEnabled,
                onChanged: (val) => setState(() => notifEnabled = val),
              ),
              const SizedBox(height: AppSpacing.p12),

              // 3. Bluetooth Card
              _PermissionCard(
                icon: Icons.bluetooth,
                title: 'Bluetooth Permission',
                subtitle: 'Simulated wireless headphone connection and status detection.',
                value: bluetoothEnabled,
                onChanged: (val) => setState(() => bluetoothEnabled = val),
              ),
              const SizedBox(height: AppSpacing.p32),

              EchoButton(
                label: 'Continue to Device Setup',
                icon: Icons.arrow_forward,
                onPressed: () {
                  try {
                    ref.read(onboardingProvider.notifier).setPermissions(
                      mic: micEnabled,
                      notif: notifEnabled,
                      bt: bluetoothEnabled,
                    );
                    ref.read(onboardingProvider.notifier).setStep(5);
                  } catch (_) {}
                  context.go('/device-setup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return EchoCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.p8),
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: AppColors.blue500, size: 24.0),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText(title, variant: EchoTextStyleVariant.labelBold),
                const SizedBox(height: 2.0),
                EchoText(
                  subtitle,
                  variant: EchoTextStyleVariant.caption,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          EchoSwitch(
            value: value,
            onChanged: onChanged,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 6. DeviceSetupScreen (/device-setup)
// Scope: Sample tag, connected, disconnected, permission-denied variants.
// =============================================================================
enum DeviceSetupStateVariant {
  connected,
  disconnected,
  permissionDenied,
}

class DeviceSetupScreen extends ConsumerStatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  ConsumerState<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends ConsumerState<DeviceSetupScreen> {
  DeviceSetupStateVariant _variant = DeviceSetupStateVariant.connected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Device Setup',
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
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EchoText('Headphone Check', variant: EchoTextStyleVariant.titleLarge),
              const SizedBox(height: AppSpacing.p4),
              const EchoText(
                'Verify your headphones before proceeding to preliminary screening.',
                variant: EchoTextStyleVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.p16),

              // Prototype state switcher for testing
              Wrap(
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p8,
                children: [
                  ChoiceChip(
                    label: const EchoText('Connected', variant: EchoTextStyleVariant.labelMedium),
                    selected: _variant == DeviceSetupStateVariant.connected,
                    selectedColor: AppColors.blue100,
                    onSelected: (_) => setState(() => _variant = DeviceSetupStateVariant.connected),
                  ),
                  ChoiceChip(
                    label: const EchoText('Disconnected', variant: EchoTextStyleVariant.labelMedium),
                    selected: _variant == DeviceSetupStateVariant.disconnected,
                    selectedColor: AppColors.blue100,
                    onSelected: (_) => setState(() => _variant = DeviceSetupStateVariant.disconnected),
                  ),
                  ChoiceChip(
                    label: const EchoText('Permission Denied', variant: EchoTextStyleVariant.labelMedium),
                    selected: _variant == DeviceSetupStateVariant.permissionDenied,
                    selectedColor: AppColors.blue100,
                    onSelected: (_) => setState(() => _variant = DeviceSetupStateVariant.permissionDenied),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p16),

              // Device Status Card Variant
              switch (_variant) {
                DeviceSetupStateVariant.connected => const EchoCard(
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_connected, color: AppColors.blue500, size: 28.0),
                        SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: AppSpacing.p8,
                                runSpacing: AppSpacing.p4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  EchoText('Headphones Connected', variant: EchoTextStyleVariant.labelLarge),
                                  SampleDataTag(),
                                ],
                              ),
                              SizedBox(height: 2.0),
                              EchoText(
                                'Bluetooth Audio Active (Simulated)',
                                variant: EchoTextStyleVariant.caption,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                DeviceSetupStateVariant.disconnected => const EchoCard(
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_disabled, color: AppColors.blue500, size: 28.0),
                        SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: AppSpacing.p8,
                                runSpacing: AppSpacing.p4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  EchoText('No Headphones Detected', variant: EchoTextStyleVariant.labelLarge),
                                  SampleDataTag(),
                                ],
                              ),
                              SizedBox(height: 2.0),
                              EchoText(
                                'Connect your headphones via Bluetooth or audio jack to continue.',
                                variant: EchoTextStyleVariant.caption,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                DeviceSetupStateVariant.permissionDenied => const EchoCard(
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.blue500, size: 28.0),
                        SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: AppSpacing.p8,
                                runSpacing: AppSpacing.p4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  EchoText('Bluetooth Permission Unavailable', variant: EchoTextStyleVariant.labelLarge),
                                  SampleDataTag(),
                                ],
                              ),
                              SizedBox(height: 2.0),
                              EchoText(
                                'Enable Bluetooth access in system settings to detect devices.',
                                variant: EchoTextStyleVariant.caption,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              },
              const SizedBox(height: AppSpacing.p24),

              // Calibration & Guidelines
              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EchoText('Screening Checklist', variant: EchoTextStyleVariant.cardTitle),
                    SizedBox(height: AppSpacing.p12),
                    _ChecklistItem(
                      step: '1',
                      title: 'Secure Fit',
                      desc: 'Ensure both left and right earcups fit comfortably.',
                    ),
                    SizedBox(height: AppSpacing.p8),
                    _ChecklistItem(
                      step: '2',
                      title: 'Quiet Environment',
                      desc: 'Minimize background noise and conversations around you.',
                    ),
                    SizedBox(height: AppSpacing.p8),
                    _ChecklistItem(
                      step: '3',
                      title: 'Moderate Volume',
                      desc: 'Set your device volume to a comfortable, moderate level.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p32),

              EchoButton(
                label: 'Continue to Screening Briefing',
                icon: Icons.arrow_forward,
                onPressed: _variant == DeviceSetupStateVariant.connected
                    ? () {
                        try {
                          ref.read(onboardingProvider.notifier).setDeviceConnection(true);
                          ref.read(onboardingProvider.notifier).completeOnboarding();
                          ref.read(onboardingProvider.notifier).setStep(6);
                        } catch (_) {}
                        context.go('/onboarding/test-intro');
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String step;
  final String title;
  final String desc;

  const _ChecklistItem({
    required this.step,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.blue100,
            shape: BoxShape.circle,
          ),
          child: EchoText(
            step,
            variant: EchoTextStyleVariant.labelMedium,
            color: AppColors.blue500,
          ),
        ),
        const SizedBox(width: AppSpacing.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EchoText(title, variant: EchoTextStyleVariant.labelBold),
              EchoText(desc, variant: EchoTextStyleVariant.caption, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 7. OnboardingTestIntroScreen (/onboarding/test-intro)
// Scope: Reads kScreeningFrequencies dynamically, starting at 1000 Hz.
// =============================================================================
class OnboardingTestIntroScreen extends ConsumerWidget {
  const OnboardingTestIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freqCount = kScreeningFrequencies.length;
    final sortedFrequencies = [...kScreeningFrequencies]..sort();
    final freqListText = '${sortedFrequencies.join(', ')} Hz';
    final startingFreq = kScreeningFrequencies.first;

    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Initial Screening Briefing',
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
          padding: const EdgeInsets.all(AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hearing, color: AppColors.blue500, size: 28.0),
                        SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: EchoText(
                            'Preliminary Tone Screening',
                            variant: EchoTextStyleVariant.cardTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    EchoText(
                      'This sound check presents a sequence of $freqCount test frequencies ($freqListText), beginning at reference $startingFreq Hz, to evaluate relative auditory response.',
                      variant: EchoTextStyleVariant.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    const EchoText(
                      'Whenever you hear a tone pulse, tap "I Hear It". If you do not hear it after several pulses, tap "I Can\'t Hear It" to test the next relative level.',
                      variant: EchoTextStyleVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),

              const EchoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EchoText('Screening Protocol', variant: EchoTextStyleVariant.cardTitle),
                    SizedBox(height: AppSpacing.p12),
                    EchoText(
                      '• Left Ear tested first across all test frequencies.\n• Button-driven interstitial transition.\n• Right Ear tested second.\n• Summary response pattern presented upon completion.',
                      variant: EchoTextStyleVariant.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p32),

              EchoButton(
                label: 'Begin Initial Screening',
                icon: Icons.play_arrow,
                onPressed: () {
                  ref.read(hearingTestProvider.notifier).startTest();
                  context.push('/test/in-progress');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
