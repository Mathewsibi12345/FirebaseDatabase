import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({Key? key}) : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  Future<void> _addEmployee() async {
    final id = _idController.text;
    final name = _nameController.text;
    final email = _emailController.text;
    final designation = _designationController.text;

    // Validate input fields
    if (id.isEmpty || name.isEmpty || email.isEmpty || designation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    // Save data to Firestore
    try {
      await FirebaseFirestore.instance.collection('employees').add({
        'id': id,
        'name': name,
        'email': email,
        'designation': designation,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee added successfully.'),
        ),
      );

      // Clear input fields after adding employee
      _idController.clear();
      _nameController.clear();
      _emailController.clear();
      _designationController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add employee: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Employee ID'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _designationController,
              decoration: const InputDecoration(labelText: 'Designation'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEmployee,
              child: const Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }
}
