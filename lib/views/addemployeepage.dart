


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({Key? key}) : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  File? _image; // Variable to store the picked image
  final picker = ImagePicker(); // Image picker instance
  bool _isLoading = false; // Track loading state

  // Function to validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Function to pick image from gallery
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Set the picked image file
      });
    }
  }

  // Function to add employee to Firestore
  Future<void> _addEmployee() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final email = _emailController.text;
    final designation = _designationController.text;

    // Check if any field is empty
    if (name.isEmpty || email.isEmpty || designation.isEmpty) {
      //if (name.isEmpty || email.isEmpty || designation.isEmpty || _image == null) {
      // Set loading state to false
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      // Set loading state to false
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    String? imageUrl;
    // Upload image to Firebase Storage if an image is picked
    if (_image != null) {
      try {
        final Reference storageReference =
            FirebaseStorage.instance.ref().child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageReference.getDownloadURL();
        });
      } catch (error) {
        print('Error uploading image: $error');
        // Handle error while uploading image
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading image. Please try again.'),
          ),
        );
        // Set loading state to false
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      // Add employee details to Firestore
      await FirebaseFirestore.instance.collection('employees').add({
        'name': name,
        'email': email,
        'designation': designation,
        'profile_image': imageUrl ?? '', // Image URL or empty string if no image
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee added successfully.'),
        ),
      );

      // Clear input fields
      _nameController.clear();
      _emailController.clear();
      _designationController.clear();

      // Navigate back to previous screen
      Navigator.pop(context, imageUrl);
    } catch (error) {
      // Handle error while adding employee to Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add employee: $error'),
        ),
      );
    } finally {
      // Set loading state to false
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _getImage, // Pick image button
                child: const Text('Pick Image'),
              ),
              if (_image != null) ...[
                SizedBox(height: 20),
                Image.file(_image!), // Display picked image
              ],
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
                onPressed: _isLoading ? null : _addEmployee, // Disable button when loading
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                child: _isLoading
                    ? CircularProgressIndicator() // Show loading indicator if _isLoading is true
                    : const Text("Submit"), // Show "Submit" text if _isLoading is false
              ),
            ],
          ),
        ),
      ),
    );
  }
}
