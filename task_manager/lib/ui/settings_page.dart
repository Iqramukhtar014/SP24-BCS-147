import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../provider/settings_provider.dart';
import '../provider/task_provider.dart';
import '../utils/notification_helper.dart';
import '../utils/export_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeToggle(context),
          
          const SizedBox(height: 8),
          
          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationToggle(context),
          _buildReminderOptions(context),
          _buildTestNotificationButton(context),
          
          const SizedBox(height: 8),
          
          // Export Section
          _buildSectionHeader(context, 'Export Tasks'),
          _buildExportPDF(context),
          _buildExportCSV(context),
          _buildExportToEmail(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isDark ? 'Dark theme enabled' : 'Light theme enabled',
            ),
            value: themeProvider.isDark,
            onChanged: (value) {
              themeProvider.setDark(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            secondary: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders for your tasks'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.setNotificationsEnabled(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildReminderOptions(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Reminder Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'When to receive task reminders',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              ...SettingsProvider.reminderOptions.map((minutes) {
                return RadioListTile<int>(
                  title: Text(settingsProvider.getReminderLabel(minutes)),
                  value: minutes,
                  groupValue: settingsProvider.reminderMinutes,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setReminderMinutes(value);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.notification_important,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Test Notification'),
        subtitle: const Text('Send a test notification to verify settings'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await NotificationHelper.instance.showTestNotification();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test notification sent!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildExportPDF(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Export to PDF'),
        subtitle: const Text('Export all tasks as PDF document'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          try {
            await ExportHelper.sharePDF(taskProvider.tasks);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF exported successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildExportCSV(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.table_chart,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Export to CSV'),
        subtitle: const Text('Export all tasks as CSV file'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          try {
            await ExportHelper.exportCSVToEmail(taskProvider.tasks);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV exported successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting CSV: $e'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildExportToEmail(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Export to Email'),
        subtitle: const Text('Share tasks via email as PDF'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          try {
            await ExportHelper.exportPDFToEmail(taskProvider.tasks);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasks ready to share via email!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting to email: $e'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

