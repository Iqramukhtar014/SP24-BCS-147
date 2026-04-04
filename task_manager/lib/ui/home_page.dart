import 'package:flutter/material.dart';
import '/ui/pages/today_task_page.dart';
import '/ui/pages/completed_task_page.dart';
import '/ui/pages/repeated_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final pages = const [
    TodayTasksPage(),
    CompletedTasksPage(),
    RepeatedTasksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),

      body: pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: "Repeated"),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/addTask");
        },
      ),
    );
  }
}
