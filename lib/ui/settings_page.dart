import 'package:flutter/material.dart';
import '../widgets/settings_widgets.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
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
                      icon: Icons.brightness_auto_outlined,
                      title: 'Follow System',
                      subtitle: 'Match system theme',
                      trailing: Switch(
                        value: themeService.themeMode == ThemeMode.system,
                        onChanged: (value) => themeService.toggleFollowSystem(value),
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Better for your eyes',
                      enabled: themeService.themeMode != ThemeMode.system,
                      trailing: Switch(
                        value: themeService.themeMode == ThemeMode.system
                            ? MediaQuery.of(context).platformBrightness == Brightness.dark
                            : themeService.themeMode == ThemeMode.dark,
                        onChanged: themeService.themeMode != ThemeMode.system
                            ? (value) => themeService.toggleDarkMode(value)
                            : null,
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Material UI',
                          subtitle: 'Use Material 3 design system',
                          trailing: Switch(
                            value: themeService.isMaterialUI,
                            onChanged: (_) => themeService.toggleMaterialUI(),
                            activeColor: colorScheme.primary,
                          ),
                        ),
                        const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.palette_outlined,
                          title: 'System Accent',
                          subtitle: 'Use wallpaper colors',
                          enabled: themeService.isMaterialUI,
                          trailing: Switch(
                            value: themeService.useSystemAccent,
                            onChanged: themeService.isMaterialUI
                                ? (_) => themeService.toggleSystemAccent()
                                : null,
                            activeColor: colorScheme.primary,
                          ),
                        ),
                        if (themeService.useSystemAccent && themeService.isMaterialUI) ...[
                          const SettingsDivider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _AccentShadeButton(
                                  label: 'Primary',
                                  isSelected: themeService.accentShade == 0,
                                  onTap: () => themeService.setAccentShade(0),
                                ),
                                _AccentShadeButton(
                                  label: 'Secondary',
                                  isSelected: themeService.accentShade == 1,
                                  onTap: () => themeService.setAccentShade(1),
                                ),
                                _AccentShadeButton(
                                  label: 'Tertiary',
                                  isSelected: themeService.accentShade == 2,
                                  onTap: () => themeService.setAccentShade(2),
                                ),
                              ],
                            ),
                          ),
                        ],
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
      },
    );
  }
}

class _AccentShadeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentShadeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
