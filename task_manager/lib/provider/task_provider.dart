import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../database/database_helper.dart';
import '../utils/notification_helper.dart';
import '../utils/export_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider();

  /// Load all tasks from database
  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getAllTasks();
    final pendingCount = _tasks.where((t) => !t.isCompleted).length;
    await NotificationHelper.instance
        .showPendingTasksNotification(pendingCount);
    notifyListeners();
  }

  /// Add a new task
  Future<void> addTask(Task t, {int? reminderMinutes}) async {
    final id = await DatabaseHelper.instance.insertTask(t);
    t.id = id;
    _tasks.add(t);

    // Schedule a notification based on settings (only if reminderMinutes is provided)
    if (t.dueDate != null && reminderMinutes != null) {
      await NotificationHelper.instance.scheduleNotification(
        t.id!,
        'Task: ${t.title}',
        t.description ?? '',
        t.dueDate!,
        reminderMinutes: reminderMinutes,
      );
    }
    notifyListeners();
  }

  /// Update an existing task
  Future<void> updateTask(Task t, {int? reminderMinutes}) async {
    if (t.id == null) return;

    await DatabaseHelper.instance.updateTask(t);
    final idx = _tasks.indexWhere((e) => e.id == t.id);
    if (idx != -1) _tasks[idx] = t;

    // Cancel previous notification and reschedule (only if reminderMinutes is provided)
    await NotificationHelper.instance.cancelNotification(t.id!);
    if (t.dueDate != null && reminderMinutes != null) {
      await NotificationHelper.instance.scheduleNotification(
        t.id!,
        'Task: ${t.title}',
        t.description ?? '',
        t.dueDate!,
        reminderMinutes: reminderMinutes,
      );
    }
    notifyListeners();
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    await NotificationHelper.instance.cancelNotification(id);
    notifyListeners();
  }

  /// Toggle task completion and handle repeating tasks
  Future<void> toggleComplete(Task t) async {
    t.isCompleted = !t.isCompleted;

    // If completed and daily repeat, create next task
    if (t.isCompleted && t.repeat == 'daily') {
      final next = Task(
        title: t.title,
        description: t.description,
        dueDate: t.dueDate?.add(const Duration(days: 1)),
        repeat: t.repeat,
        subtasks: t.subtasks.map((s) => Subtask(title: s.title)).toList(),
      );
      await addTask(next);
    }

    await updateTask(t);
  }

  /// Filter tasks for today
  List<Task> todayTasks() {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day &&
          !t.isCompleted;
    }).toList();
  }

  /// Completed tasks
  List<Task> completedTasks() => _tasks.where((t) => t.isCompleted).toList();

  /// Tasks with any repetition
  List<Task> repeatedTasks() => _tasks.where((t) => t.repeat != 'none').toList();

  /// Export tasks as CSV
  Future<String> exportCSV() async => ExportHelper.exportToCSV(_tasks);

  /// Export tasks as PDF bytes
  Future<Uint8List> exportPDFBytes() async => ExportHelper.exportToPDFBytes(_tasks);

  /// Share PDF of tasks
  Future<void> sharePDF() async => ExportHelper.sharePDF(_tasks);
}
