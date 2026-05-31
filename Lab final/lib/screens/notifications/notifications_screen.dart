import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// ─── NOTIFICATIONS SCREEN ────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style: TextStyle(color: AppTheme.primaryPurple, fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: FirebaseService.getNotifications(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          final notifs = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NotifTile(notif: notifs[i]),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;

  const _NotifTile({required this.notif});

  Color get _color {
    switch (notif.type) {
      case 'payment':
        return AppTheme.success;
      case 'expiry':
        return AppTheme.warning;
      case 'alert':
        return AppTheme.error;
      default:
        return AppTheme.info;
    }
  }

  IconData get _icon {
    switch (notif.type) {
      case 'payment':
        return Icons.payment_outlined;
      case 'expiry':
        return Icons.card_membership_outlined;
      case 'alert':
        return Icons.warning_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FirebaseService.markNotificationRead(notif.id),
      child: DarkCard(
        padding: const EdgeInsets.all(14),
        color: notif.isRead ? null : AppTheme.cardDark2,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: notif.isRead
                              ? FontWeight.w500
                              : FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(notif.time,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── SETTINGS SCREEN ─────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _theme = 'Dark';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text('Admin',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Text(auth.user?.email ?? 'admin@gmail.com',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
            // Settings tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) =>
                        setState(() => _notificationsEnabled = v),
                    activeColor: AppTheme.primaryPurple,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  trailing: Text(_theme,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: Text(_language,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Gym Management System',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Gym Management',
                  ),
                ),
                const SizedBox(height: 16),
                // Logout
                GestureDetector(
                  onTap: () async {
                    final ok = await showConfirmDialog(context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?');
                    if (ok) {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.error.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.logout, color: AppTheme.error),
                      const SizedBox(width: 14),
                      const Text('Logout',
                          style: TextStyle(
                              color: AppTheme.error,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile(
      {required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DarkCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14)),
          ),
          trailing ??
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted, size: 20),
        ]),
      ),
    );
  }
}
