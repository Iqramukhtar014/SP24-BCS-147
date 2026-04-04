import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationHelper {
  // ✅ Singleton setup
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  // ✅ Optional getter to use `.instance`
  static NotificationHelper get instance => _instance;
  static const int _pendingSummaryNotificationId = 100001;

  // ✅ Initialize awesome notifications
  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notifications for scheduled tasks with awesome design',
          defaultColor: Color(0xFF2196F3),
          ledColor: Color(0xFF2196F3),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      debug: kDebugMode,
    );

    // Request permission for notifications
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // ✅ Schedule a notification with reminder minutes
  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime,
      {int reminderMinutes = 10}) async {
    // Calculate notification time (subtract reminder minutes)
    final notificationTime = scheduledTime.subtract(Duration(minutes: reminderMinutes));
    
    // Don't schedule if time has already passed
    if (notificationTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot schedule notification in the past');
      }
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: '📋 $title',
        body: body,
        notificationLayout: NotificationLayout.BigText,
        bigPicture: null,
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        color: Color(0xFF2196F3),
        backgroundColor: Color(0xFFFFFFFF),
        payload: {'taskId': id.toString()},
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: false,
      ),
      schedule: NotificationCalendar.fromDate(
        date: notificationTime,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  // ✅ Show test notification immediately
  Future<void> showTestNotification() async {
    const id = 999999; // Special ID for test notifications
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: '📋 Test Notification',
        body: 'This is a test notification from Task Manager! Your notifications are working perfectly. You will receive reminders for your tasks based on your settings.',
        notificationLayout: NotificationLayout.BigText,
        bigPicture: null,
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        color: Color(0xFF2196F3),
        backgroundColor: Color(0xFFFFFFFF),
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
        fullScreenIntent: false,
        criticalAlert: false,
      ),
    );
  }

  // ✅ Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // ✅ Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // ✅ Cancel notifications by channel
  Future<void> cancelNotificationsByChannelKey(String channelKey) async {
    await AwesomeNotifications().cancelNotificationsByChannelKey(channelKey);
  }

  /// ✅ Show an immediate summary about remaining tasks
  Future<void> showPendingTasksNotification(int pendingCount) async {
    await AwesomeNotifications().cancel(_pendingSummaryNotificationId);

    if (pendingCount <= 0) {
      return;
    }

    final plural = pendingCount == 1 ? 'task' : 'tasks';
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _pendingSummaryNotificationId,
        channelKey: 'task_channel',
        title: 'You have $pendingCount $plural left',
        body: 'Keep going! Complete the remaining $plural to stay on track.',
        notificationLayout: NotificationLayout.BigText,
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }
}
