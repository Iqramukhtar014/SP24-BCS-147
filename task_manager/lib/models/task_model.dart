import 'dart:convert';

class Subtask {
  int? id;
  String title;
  bool done;

  Subtask({this.id, required this.title, this.done = false});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'done': done ? 1 : 0,
  };

  factory Subtask.fromMap(Map<String, dynamic> m) => Subtask(
    id: m['id'],
    title: m['title'] ?? '',
    done: (m['done'] ?? 0) == 1,
  );
}

class Task {
  int? id;
  String title;
  String? description;
  DateTime? dueDate;
  bool isCompleted;
  String repeat; // 'none', 'daily', 'weekly', or comma days like 'mon,tue'
  List<Subtask> subtasks;

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.repeat = 'none',
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

  // ------------------ ADD THIS ------------------
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? repeat,
    List<Subtask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeat: repeat ?? this.repeat,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  double progress() {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final done = subtasks.where((s) => s.done).length;
    return done / subtasks.length;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted ? 1 : 0,
    'repeat': repeat,
    'subtasks': jsonEncode(subtasks.map((s) => s.toMap()).toList()),
  };

  factory Task.fromMap(Map<String, dynamic> m) {
    List<Subtask> subs = [];
    final subsJson = m['subtasks'] as String?;
    if (subsJson != null && subsJson.isNotEmpty) {
      try {
        final List decoded = jsonDecode(subsJson);
        subs = decoded
            .map((e) => Subtask.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    return Task(
      id: m['id'] as int?,
      title: m['title'] ?? '',
      description: m['description'],
      dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
      isCompleted: (m['isCompleted'] ?? 0) == 1,
      repeat: m['repeat'] ?? 'none',
      subtasks: subs,
    );
  }
}
