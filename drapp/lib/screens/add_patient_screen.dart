import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/patient_model.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final diseaseController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String gender = "Male";

  void savePatient() async {

    final patient = Patient(
      name: nameController.text,
      age: ageController.text,
      gender: gender,
      disease: diseaseController.text,
      phone: phoneController.text,
      address: addressController.text,
    );

    await DatabaseHelper.instance.insertPatient(patient);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Add Patient")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),

            TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age")),

            DropdownButtonFormField(
              value: gender,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (value){
                gender = value!;
              },
            ),

            TextField(controller: diseaseController, decoration: const InputDecoration(labelText: "Disease")),

            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),

            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: savePatient,
              child: const Text("Save Patient"),
            )
          ],
        ),
      ),
    );
  }
}