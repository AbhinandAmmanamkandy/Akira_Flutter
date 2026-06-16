import 'package:flutter/material.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/services/theme_service.dart';
import 'widgets/settings_components.dart';
import 'widgets/accent_shade_button.dart';
import 'widgets/settings_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
        final colorScheme = Theme.of(context).colorScheme;
        final useGlass = themeService.useGlassTheme;

        return Scaffold(
          body: SettingsBackground(
            child: OverscrollDismissGesture(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: useGlass ? Colors.transparent : colorScheme.surface.withValues(alpha: 0.8),
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    iconTheme: IconThemeData(color: colorScheme.onSurface),
                    flexibleSpace: useGlass 
                      ? const GlassContainer(
                          borderRadius: 0,
                          withBlur: true,
                          opacity: 0.05,
                          child: FlexibleSpaceBar(),
                        )
                      : null,
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    centerTitle: true,
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
                              activeThumbColor: colorScheme.primary,
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
                              activeThumbColor: colorScheme.primary,
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
                              activeThumbColor: colorScheme.primary,
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: Icons.blur_on_rounded,
                            title: 'Glass Theme',
                            subtitle: 'Apply frosted glass effects',
                            trailing: Switch(
                              value: themeService.useGlassTheme,
                              onChanged: (_) => themeService.toggleGlassTheme(),
                              activeThumbColor: colorScheme.primary,
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: Icons.swipe_down_rounded,
                            title: 'Overscroll to Close',
                            subtitle: 'Swipe down on any page to close',
                            trailing: Switch(
                              value: themeService.useOverscrollToClose,
                              onChanged: (_) => themeService.toggleOverscrollToClose(),
                              activeThumbColor: colorScheme.primary,
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
                              activeThumbColor: colorScheme.primary,
                            ),
                          ),
                          if (themeService.useSystemAccent && themeService.isMaterialUI) ...[
                            const SettingsDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  AccentShadeButton(
                                    label: 'Primary',
                                    isSelected: themeService.accentShade == 0,
                                    onTap: () => themeService.setAccentShade(0),
                                  ),
                                  AccentShadeButton(
                                    label: 'Secondary',
                                    isSelected: themeService.accentShade == 1,
                                    onTap: () => themeService.setAccentShade(1),
                                  ),
                                  AccentShadeButton(
                                    label: 'Tertiary',
                                    isSelected: themeService.accentShade == 2,
                                    onTap: () => themeService.setAccentShade(2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SettingsSectionHeader(title: 'CONTENT'),
                      SettingsCard(
                        children: [
                          SettingsTile(
                            icon: Icons.explicit_outlined,
                            title: 'Allow Adult Content',
                            subtitle: 'Include 18+ content in search',
                            trailing: Switch(
                              value: themeService.allowAdult,
                              onChanged: (_) => themeService.toggleAllowAdult(),
                              activeThumbColor: colorScheme.primary,
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Allow Unknown Content',
                            subtitle: 'Include content with unknown rating',
                            trailing: Switch(
                              value: themeService.allowUnknown,
                              onChanged: (_) => themeService.toggleAllowUnknown(),
                              activeThumbColor: colorScheme.primary,
                            ),
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
          ),
        );
      },
    );
  }
}
