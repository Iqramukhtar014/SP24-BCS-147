import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../provider/task_provider.dart';
import '../provider/settings_provider.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;
  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _form = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _due;
  String _repeat = 'none';
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _due = widget.task!.dueDate;
      _repeat = widget.task!.repeat;
      _subtasks = widget.task!.subtasks
          .map((s) => Subtask(id: s.id, title: s.title, done: s.done))
          .toList();
    } else {
      _title = '';
    }
  }

  Future<void> _pickDateTime() async {
    if (!mounted) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _due ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    setState(() {
      _due = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _addSubtask() {
    setState(() => _subtasks.add(Subtask(title: '', done: false)));
  }

  Future<void> _saveTask() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    final newTask = Task(
      id: widget.task?.id,
      title: _title,
      description: _description,
      dueDate: _due,
      isCompleted: widget.task?.isCompleted ?? false,
      repeat: _repeat,
      subtasks: _subtasks,
    );

    // Use context.read instead of Provider.of for async safety
    final taskProv = context.read<TaskProvider>();
    final settingsProv = context.read<SettingsProvider>();

    // Get reminder minutes from settings if notifications are enabled
    int? reminderMinutes;
    if (settingsProv.notificationsEnabled) {
      reminderMinutes = settingsProv.reminderMinutes;
    }

    // Perform async operations
    if (widget.task == null) {
      await taskProv.addTask(newTask, reminderMinutes: reminderMinutes);
    } else {
      await taskProv.updateTask(newTask, reminderMinutes: reminderMinutes);
    }

    // Safe navigation after async
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              TextFormField(
                initialValue: _description ?? '',
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => _description = v?.trim(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _due == null
                          ? 'No date chosen'
                          : DateFormat.yMd().add_jm().format(_due!),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Pick Date & Time'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _repeat,
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('No repeat')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => setState(() => _repeat = v ?? 'none'),
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtasks'),
                  TextButton(onPressed: _addSubtask, child: const Text('Add')),
                ],
              ),
              ..._subtasks.asMap().entries.map((e) {
                final idx = e.key;
                final st = e.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: st.title,
                        decoration:
                        const InputDecoration(hintText: 'Subtask title'),
                        onChanged: (v) => st.title = v,
                      ),
                    ),
                    Checkbox(
                      value: st.done,
                      onChanged: (v) => setState(() => st.done = v ?? false),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _subtasks.removeAt(idx)),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
