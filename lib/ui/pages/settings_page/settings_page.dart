import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/services/backup_service.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/ui/pages/history_page/history_page.dart';
import 'package:akira/ui/pages/downloads_page/downloads_page.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/ui/widgets/common_chip.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
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
        final isMaterial = themeService.isMaterialUI;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SettingsBackground(
            child: OverscrollDismissGesture(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildSliverAppBar(context, themeService, colorScheme),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHero(context, themeService, colorScheme),
                          
                          SettingsGroup(
                            title: 'Design & Aesthetics',
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.auto_awesome_outlined,
                                title: 'Material You',
                                subtitle: 'Modern dynamic design system',
                                value: themeService.isMaterialUI,
                                onChanged: (_) => themeService.toggleMaterialUI(),
                              ),
                              if (themeService.isMaterialUI) ...[
                                SettingsSwitchTile(
                                  icon: Icons.palette_outlined,
                                  title: 'Dynamic Palette',
                                  subtitle: 'Extract colors from your wallpaper',
                                  value: themeService.useSystemAccent,
                                  onChanged: (_) => themeService.toggleSystemAccent(),
                                ),
                                if (themeService.useSystemAccent)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(72, 4, 24, 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              SettingsSwitchTile(
                                icon: Icons.blur_on_rounded,
                                title: 'Glassmorphism',
                                subtitle: 'Apply frosted translucency effects',
                                value: themeService.useGlassTheme,
                                onChanged: (_) => themeService.toggleGlassTheme(),
                              ),
                            ],
                          ),

                          SettingsGroup(
                            title: 'System Theme',
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.brightness_auto_outlined,
                                title: 'Auto Mode',
                                subtitle: 'Follow system brightness',
                                value: themeService.themeMode == ThemeMode.system,
                                onChanged: (val) => themeService.toggleFollowSystem(val),
                              ),
                              SettingsSwitchTile(
                                icon: Icons.dark_mode_outlined,
                                title: 'Dark Universe',
                                subtitle: 'Deep blacks for OLED screens',
                                enabled: themeService.themeMode != ThemeMode.system,
                                value: themeService.themeMode == ThemeMode.system
                                    ? MediaQuery.of(context).platformBrightness == Brightness.dark
                                    : themeService.themeMode == ThemeMode.dark,
                                onChanged: (val) => themeService.toggleDarkMode(val),
                              ),
                            ],
                          ),

                          SettingsGroup(
                            title: 'Streaming & Media',
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.explicit_outlined,
                                title: 'Mature Content',
                                subtitle: 'Include 18+ titles in exploration',
                                value: themeService.allowAdult,
                                onChanged: (_) => themeService.toggleAllowAdult(),
                              ),
                              SettingsTile(
                                icon: Icons.speed_rounded,
                                title: 'Engine Threads',
                                subtitle: 'Current: ${themeService.downloadThreads} parallel connections',
                                trailing: CommonChip(
                                  label: '${themeService.downloadThreads}',
                                  isSelected: true,
                                  onTap: () => _showThreadSelector(context, themeService, colorScheme),
                                ),
                                onTap: () => _showThreadSelector(context, themeService, colorScheme),
                              ),
                            ],
                          ),

                          SettingsGroup(
                            title: 'Library Management',
                            children: [
                              SettingsTile(
                                icon: Icons.history_rounded,
                                title: 'Watch History',
                                subtitle: 'Clear or view your recent activity',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage())),
                              ),
                              SettingsTile(
                                icon: Icons.download_done_rounded,
                                title: 'Media Manager',
                                subtitle: 'Browse your offline collection',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadsPage())),
                              ),
                              SettingsTile(
                                icon: Icons.layers_clear_outlined,
                                title: 'Wipe History',
                                iconColor: Colors.redAccent,
                                onTap: () => _showClearHistoryDialog(context, colorScheme),
                              ),
                            ],
                          ),

                          SettingsGroup(
                            title: 'Cloud & Synchronization',
                            children: [
                              SettingsTile(
                                icon: Icons.backup_outlined,
                                title: 'Create Backup',
                                subtitle: 'Save your profile to local storage',
                                onTap: () => BackupService.exportToFile(),
                              ),
                              SettingsTile(
                                icon: Icons.restore_rounded,
                                title: 'Restore Data',
                                subtitle: 'Import your previous session',
                                onTap: () => _showImportDialog(context),
                              ),
                            ],
                          ),

                          SettingsGroup(
                            title: 'Advanced Settings',
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.swipe_down_rounded,
                                title: 'Swipe Dismiss',
                                subtitle: 'Overscroll down to close pages',
                                value: themeService.useOverscrollToClose,
                                onChanged: (_) => themeService.toggleOverscrollToClose(),
                              ),
                              SettingsSwitchTile(
                                icon: Icons.lightbulb_outline_rounded,
                                title: 'System Tips',
                                subtitle: 'Show helpful hints across the app',
                                value: themeService.showTooltips,
                                onChanged: (_) => themeService.toggleShowTooltips(),
                              ),
                            ],
                          ),

                          _buildAppInfo(context, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeService themeService, ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'CONTROL CENTER',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 6,
          fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, ThemeService themeService, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      width: 8,
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      themeService.username.isNotEmpty ? themeService.username[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            themeService.username.isNotEmpty ? themeService.username : 'Nameless Hero',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              themeService.gender.isNotEmpty ? themeService.gender.toUpperCase() : 'WANDERER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/icon/akira.png',
                width: 50,
                height: 50,
                errorBuilder: (_, __, ___) => Icon(Icons.movie_filter_rounded, size: 50, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AKIRA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'v1.1.0 • Stable Release',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.code_rounded, () {}),
                const SizedBox(width: 32),
                _buildSocialButton(Icons.discord_rounded, () {}),
                const SizedBox(width: 32),
                _buildSocialButton(Icons.favorite_rounded, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 24, color: Colors.grey.withValues(alpha: 0.4)),
      ),
    );
  }

  void _showThreadSelector(BuildContext context, ThemeService themeService, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 40,
        withBlur: true,
        opacity: 0.1,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ENGINE THREADS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the number of simultaneous connections for faster downloads.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [1, 2, 4, 6, 8].map((e) => CommonChip(
                label: '$e Threads',
                isSelected: themeService.downloadThreads == e,
                onTap: () {
                  themeService.setDownloadThreads(e);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 40,
        withBlur: true,
        opacity: 0.1,
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Import Data',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Restore your favorites, history, and preferences from a JSON backup.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final success = await BackupService.importFromFile();
                if (context.mounted) {
                  Navigator.pop(context);
                  _showImportResult(context, success);
                }
              },
              icon: const Icon(Icons.file_present_rounded),
              label: const Text('SELECT BACKUP FILE'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR PASTE TEXT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
            ),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                hintText: '{ "favorites": [...], ... }',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final success = await BackupService.importData(controller.text);
                      if (context.mounted) {
                        Navigator.pop(context);
                        _showImportResult(context, success);
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('IMPORT TEXT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImportResult(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'System Data Restored' : 'Import Failed: Invalid JSON'),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 32,
          withBlur: true,
          opacity: 0.1,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 20),
              const Text('Initiate Wipe?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text(
                'This will permanently delete all your watch and reading activity. Proceed with caution.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ABORT'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HistoryService().clearHistory();
                        Navigator.pop(context);
                        _showImportResult(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('WIPE ALL', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupOptions(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 40,
        withBlur: true,
        opacity: 0.1,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BACKUP & RESTORE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.upload_file_rounded, color: colorScheme.primary),
              ),
              title: const Text('Export to Storage', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Create a local backup file', style: TextStyle(fontSize: 12)),
              onTap: () { Navigator.pop(context); BackupService.exportToFile(); },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorScheme.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.file_download_outlined, color: colorScheme.secondary),
              ),
              title: const Text('Import from Storage', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Restore from a backup file', style: TextStyle(fontSize: 12)),
              onTap: () { Navigator.pop(context); _showImportDialog(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
