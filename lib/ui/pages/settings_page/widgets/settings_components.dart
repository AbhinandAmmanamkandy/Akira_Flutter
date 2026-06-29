import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/ui/widgets/glass_container.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isMaterial = themeService.isMaterialUI;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colorScheme.primary.withValues(alpha: 0.9),
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 4.0,
          fontFamily: isMaterial ? null : GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const SettingsGroup({super.key, required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SettingsSectionHeader(title: title!),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: GlassContainer(
            borderRadius: 36,
            withBlur: true,
            opacity: useGlass ? 0.04 : 0.6,
            blur: 25,
            color: colorScheme.surfaceContainer,
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              width: 1.5,
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 72, right: 24),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isMaterial = themeService.isMaterialUI;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (iconColor ?? colorScheme.primary).withValues(alpha: 0.15),
                      (iconColor ?? colorScheme.primary).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: enabled 
                      ? (iconColor ?? colorScheme.primary) 
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        fontFamily: isMaterial ? null : GoogleFonts.poppins().fontFamily,
                        color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: enabled
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: isMaterial ? null : GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
        activeColor: colorScheme.primary,
        inactiveThumbColor: colorScheme.onSurface.withValues(alpha: 0.2),
        inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.05),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      onTap: enabled ? () => onChanged(!value) : null,
    );
  }
}
