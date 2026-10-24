import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/navigation/echo_setting_row.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

/// Tab 4: Profile & Settings Screen matching Board 1 Screen 15.
/// Features profile card, categorized setting groups with [EchoSettingRow],
/// custom switches, dividers, and deep navigation to sub-settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _screeningReminders = true;
  bool _soundLevelAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Profile & Settings',
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
              // 1. Profile Overview Card
              EchoCard(
                child: Row(
                  children: [
                    Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: const BoxDecoration(
                        color: AppColors.blue100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: AppColors.blue500,
                          size: 32.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EchoText('Alex Parker', variant: EchoTextStyleVariant.titleMedium),
                          const SizedBox(height: 2.0),
                          const EchoText(
                            'Standard Listening Profile',
                            variant: EchoTextStyleVariant.caption,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.p6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.p8,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue100,
                              borderRadius: AppRadii.roundedPill,
                              border: Border.all(color: AppColors.blue400, width: 1.0),
                            ),
                            child: Text(
                              'Active Profile',
                              style: AppTypography.captionBold.copyWith(
                                color: AppColors.blue500,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 2. Section: Connected Devices & Audio
              _buildSectionHeader('Devices & Audio Output'),
              const SizedBox(height: AppSpacing.p8),
              EchoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    EchoSettingRow(
                      icon: Icons.headphones,
                      title: 'Connected Devices',
                      subtitle: 'WH-1000XM4 (Simulated)',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/devices'),
                      showDivider: true,
                    ),
                    EchoSettingRow(
                      icon: Icons.tune,
                      title: 'Equalization Profile',
                      subtitle: 'Calibrated based on latest screening',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/devices'),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 3. Section: Screening & Notifications
              _buildSectionHeader('Alerts & Monitoring'),
              const SizedBox(height: AppSpacing.p8),
              EchoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    EchoSettingRow(
                      icon: Icons.alarm,
                      title: 'Screening Reminders',
                      subtitle: 'Monthly auditory check-in reminder',
                      trailing: Switch.adaptive(
                        value: _screeningReminders,
                        activeTrackColor: AppColors.blue500,
                        onChanged: (val) => setState(() => _screeningReminders = val),
                      ),
                      showDivider: true,
                    ),
                    EchoSettingRow(
                      icon: Icons.volume_up_outlined,
                      title: 'Sound Exposure Alerts',
                      subtitle: 'Notification when daily exposure is elevated',
                      trailing: Switch.adaptive(
                        value: _soundLevelAlerts,
                        activeTrackColor: AppColors.blue500,
                        onChanged: (val) => setState(() => _soundLevelAlerts = val),
                      ),
                      showDivider: true,
                    ),
                    EchoSettingRow(
                      icon: Icons.notifications_none,
                      title: 'Notification Preferences',
                      subtitle: 'Manage alert sounds and frequency',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/notifications'),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 4. Section: Privacy & Data
              _buildSectionHeader('Privacy & Data'),
              const SizedBox(height: AppSpacing.p8),
              EchoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    EchoSettingRow(
                      icon: Icons.lock_outline,
                      title: 'Privacy & Data Protection',
                      subtitle: 'On-device simulated processing',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/privacy'),
                      showDivider: true,
                    ),
                    EchoSettingRow(
                      icon: Icons.file_download_outlined,
                      title: 'Export Screening Data',
                      subtitle: 'Download complete screening history',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/export'),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // 5. Section: Support & About
              _buildSectionHeader('About & Support'),
              const SizedBox(height: AppSpacing.p8),
              EchoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    EchoSettingRow(
                      icon: Icons.help_outline,
                      title: 'Help & Knowledge Base',
                      subtitle: 'Acoustic guidance and FAQ',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/help'),
                      showDivider: true,
                    ),
                    EchoSettingRow(
                      icon: Icons.info_outline,
                      title: 'About ECHO',
                      subtitle: 'Version 1.0.0 • Monochromatic UI',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => context.push('/profile/about'),
                      showDivider: false,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
      child: Text(
        title,
        style: AppTypography.labelBold.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12.0,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Connected Devices', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Wireless Headphones', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p4),
                EchoText('Connected via Bluetooth • Audio profile applied', variant: EchoTextStyleVariant.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Notifications', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Listening Alerts', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p4),
                EchoText('Daily 80% sound dose alert active.', variant: EchoTextStyleVariant.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Privacy & Data', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('On-Device Processing', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p4),
                EchoText('All sound monitoring and screening metrics remain strictly on-device.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Export Data', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Export Screening History', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p4),
                EchoText('Export your personal acoustic metrics in JSON format for offline review.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef AboutEchoScreen = AboutScreen;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'About ECHO', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('ECHO Audio Companion', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Version 1.0.0 (Build 2026.10)', variant: EchoTextStyleVariant.caption),
                SizedBox(height: AppSpacing.p12),
                EchoText(
                  'ECHO is an illustrative hearing screening and sound exposure companion. All metrics and tone responses are indicative preliminary estimates.',
                  variant: EchoTextStyleVariant.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Help & FAQ', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Frequently Asked Questions', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p12),
                EchoText('How is relative sound level determined?', variant: EchoTextStyleVariant.labelBold),
                SizedBox(height: AppSpacing.p4),
                EchoText('Sound levels represent non-clinical, software-calibrated audio steps from Level 1 to 13.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
