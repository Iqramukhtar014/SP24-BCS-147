import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/patient_model.dart';
import '../widgets/patient_card.dart';
import 'add_patient_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Patient> patients = [];

  void loadPatients() async {
    final data = await DatabaseHelper.instance.getPatients();
    setState(() {
      patients = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Patient Records",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {

          final patient = patients[index];

          return PatientCard(
            patient: patient,
            refresh: loadPatients,
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add),
        label: const Text("Add Patient"),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddPatientScreen()));
          loadPatients();
        },
      ),
    );
  }
}