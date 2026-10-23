import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Profile & Settings', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EchoCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.0,
                      backgroundColor: AppColors.blue100,
                      child: Icon(Icons.person, color: AppColors.blue500, size: 32.0),
                    ),
                    SizedBox(width: AppSpacing.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EchoText('Alex Parker', variant: EchoTextStyleVariant.titleMedium),
                          EchoText('Standard Listening Profile', variant: EchoTextStyleVariant.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              EchoButton(
                label: 'Connected Devices',
                icon: Icons.headphones,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/devices'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Notifications',
                icon: Icons.notifications_none,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/notifications'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Privacy & Data',
                icon: Icons.lock_outline,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/privacy'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Export Data',
                icon: Icons.file_download_outlined,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/export'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'About ECHO',
                icon: Icons.info_outline,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/about'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Help & FAQ',
                icon: Icons.help_outline,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/profile/help'),
              ),
            ],
          ),
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
                EchoText('Export Records', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p4),
                EchoText('Export your preliminary screening records as a JSON or CSV file.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                EchoText('ECHO Mobile v1.0.0', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Consumer hearing monitoring and sound wellness platform.', variant: EchoTextStyleVariant.bodyMedium),
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
                SizedBox(height: AppSpacing.p8),
                EchoText('How often should I run the preliminary screening? We recommend once every 2–4 weeks.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
