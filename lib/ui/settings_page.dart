import 'package:flutter/material.dart';

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
                _buildSectionHeader(context, 'ACCOUNT'),
                _buildCard(
                  context,
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: 'Edit your profile info',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Sound, vibration, and more',
                      onTap: () {},
                    ),
                  ],
                ),
                _buildSectionHeader(context, 'PREFERENCES'),
                _buildCard(
                  context,
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Better for your eyes',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.palette_outlined,
                      title: 'Accent Color',
                      subtitle: 'Customize app theme',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.translate_rounded,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                  ],
                ),
                _buildSectionHeader(context, 'SUPPORT'),
                _buildCard(
                  context,
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      onTap: () {},
                    ),
                  ],
                ),
                _buildSectionHeader(context, 'ABOUT'),
                _buildCard(
                  context,
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
