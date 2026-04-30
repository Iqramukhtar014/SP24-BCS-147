// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: Icons.volume_up_rounded,
                    iconColor: AppTheme.primary,
                    title: 'Sound',
                    subtitle: 'Play sound effects',
                    value: provider.soundEnabled,
                    onChanged: (v) => provider.toggleSound(v),
                    showDivider: true,
                  ),
                  _buildToggleTile(
                    icon: Icons.vibration_rounded,
                    iconColor: AppTheme.primary,
                    title: 'Vibration',
                    subtitle: 'Enable vibration',
                    value: provider.vibrationEnabled,
                    onChanged: (v) => provider.toggleVibration(v),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _buildNavTile(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.primary,
                    title: 'About Game',
                    subtitle: 'Learn more about this game',
                    onTap: () => _showAboutDialog(context),
                    showDivider: true,
                  ),
                  _buildNavTile(
                    context: context,
                    icon: Icons.restart_alt_rounded,
                    iconColor: AppTheme.error,
                    title: 'Reset Game',
                    subtitle: 'Clear all history and stats',
                    onTap: () => _confirmReset(context, provider),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Version info
            Center(
              child: Text(
                'Number Guessing Game v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textMuted),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Number Guessing Game',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A fun number guessing game with three difficulty levels. '
          'Test your luck and track your stats!',
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Game'),
        content: const Text(
            'This will clear ALL history and stats. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game data has been reset'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            child: const Text('Reset',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
