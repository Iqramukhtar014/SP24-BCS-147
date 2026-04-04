import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../provider/task_provider.dart';
import '../../models/task_model.dart';
import '../add_edit_task_page.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, prov, child) {
        final DateTime today = DateTime.now();
        final dateFormat = DateFormat.yMMMd().add_jm();

        final List<Task> todayTasks = prov.tasks.where((Task task) {
          if (task.dueDate == null) return false;

          final DateTime due = task.dueDate!;
          return due.year == today.year &&
              due.month == today.month &&
              due.day == today.day &&
              !task.isCompleted;
        }).toList();

        if (todayTasks.isEmpty) {
          return const Center(
            child: Text(
              "No tasks for today!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: todayTasks.length,
          itemBuilder: (context, index) {
            final Task task = todayTasks[index];
            final description = task.description?.trim();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (description != null && description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (task.dueDate != null)
                      Text(
                        'Due ${dateFormat.format(task.dueDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.8),
                            ),
                      ),
                  ],
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle),
                      color: Colors.green,
                      tooltip: 'Mark as completed',
                      onPressed: task.isCompleted
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await prov.toggleComplete(task);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '"${task.title}" moved to completed',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTaskPage(task: task),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
