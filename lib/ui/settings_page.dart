import 'package:flutter/material.dart';
import '../widgets/settings_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              surfaceTintColor: Colors.transparent,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                const SettingsSectionHeader(title: 'ACCOUNT'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: 'Edit your profile info',
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Sound, vibration, and more',
                      onTap: () {},
                    ),
                  ],
                ),
                const SettingsSectionHeader(title: 'PREFERENCES'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Better for your eyes',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Accent Color',
                      subtitle: 'Customize app theme',
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.translate_rounded,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                  ],
                ),
                const SettingsSectionHeader(title: 'SUPPORT'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      onTap: () {},
                    ),
                  ],
                ),
                const SettingsSectionHeader(title: 'ABOUT'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.policy_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Akira Anime App',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
