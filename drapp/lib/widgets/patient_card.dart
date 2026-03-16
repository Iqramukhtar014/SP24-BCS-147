import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../database/database_helper.dart';
import '../screens/edit_patient_screen.dart';

class PatientCard extends StatelessWidget {

  final Patient patient;
  final VoidCallback refresh;

  const PatientCard({
    super.key,
    required this.patient,
    required this.refresh
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(

        leading: const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage("assets/user.png"),
        ),

        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.disease,
              style: const TextStyle(color: Colors.deepOrange),
            ),
            Text(patient.phone),
          ],
        ),

        trailing: Column(
          children: [

            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPatientScreen(patient: patient),
                  ),
                );

                refresh();
              },
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () async {

                await DatabaseHelper.instance.deletePatient(patient.id!);
                refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}