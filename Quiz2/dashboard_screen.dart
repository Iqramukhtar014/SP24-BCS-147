import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() {
    users = DatabaseHelper.instance.getUsers();
  }

  void deleteUser(int id) async {

    await DatabaseHelper.instance.deleteUser(id);

    setState(() {
      loadUsers();
    });
  }

  Widget userCard(User user) {

    return Card(

      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(

        leading: CircleAvatar(
          child: Text(user.name[0].toUpperCase()),
        ),

        title: Text(user.name),

        subtitle: Text(user.email),

        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),

          onPressed: () {
            deleteUser(user.id!);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: FutureBuilder<List<User>>(

          future: users,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No users found"),
              );
            }

            final data = snapshot.data!;

            return ListView.builder(

              itemCount: data.length,

              itemBuilder: (context, index) {

                return userCard(data[index]);
              },
            );
          },
        ),
      ),
    );
  }
}