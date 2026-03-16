import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../database/database_helper.dart';

class EditPatientScreen extends StatefulWidget {

  final Patient patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController diseaseController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  late String gender;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.patient.name);
    ageController = TextEditingController(text: widget.patient.age);
    diseaseController = TextEditingController(text: widget.patient.disease);
    phoneController = TextEditingController(text: widget.patient.phone);
    addressController = TextEditingController(text: widget.patient.address);
    gender = widget.patient.gender;
  }

  void updatePatient() async {

    final updated = Patient(
      id: widget.patient.id,
      name: nameController.text,
      age: ageController.text,
      gender: gender,
      disease: diseaseController.text,
      phone: phoneController.text,
      address: addressController.text,
    );

    await DatabaseHelper.instance.updatePatient(updated);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Edit Patient")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            TextField(controller: nameController),

            TextField(controller: ageController),

            TextField(controller: diseaseController),

            TextField(controller: phoneController),

            TextField(controller: addressController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updatePatient,
              child: const Text("Update Patient"),
            )
          ],
        ),
      ),
    );
  }
}