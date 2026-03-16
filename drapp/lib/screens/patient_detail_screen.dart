import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientDetailScreen extends StatelessWidget {

  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Patient Details")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/user.png"),
              ),
            ),

            const SizedBox(height: 20),

            Text("Name: ${patient.name}"),
            Text("Age: ${patient.age}"),
            Text("Gender: ${patient.gender}"),
            Text("Disease: ${patient.disease}"),
            Text("Phone: ${patient.phone}"),
            Text("Address: ${patient.address}"),
          ],
        ),
      ),
    );
  }
}