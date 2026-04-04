import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/task_provider.dart';
import '../../models/task_model.dart';
import 'package:intl/intl.dart';
import '../add_edit_task_page.dart';

class RepeatedTasksPage extends StatelessWidget {
  const RepeatedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, prov, _) {
      final tasks = prov.repeatedTasks();

      if (tasks.isEmpty) {
        return const Center(child: Text('No repeated tasks'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) => RepeatTile(task: tasks[index]),
      );
    });
  }
}

class RepeatTile extends StatelessWidget {
  final Task task;
  const RepeatTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => prov.toggleComplete(task),
        ),

        title: Text(task.title),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null)
              Text(DateFormat.yMd().add_jm().format(task.dueDate!)),
            Text('Repeat: ${task.repeat}'),
            LinearProgressIndicator(value: task.progress()),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskPage(task: task),
                ),
              );
            } else if (value == 'delete') {
              await prov.deleteTask(task.id!);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
