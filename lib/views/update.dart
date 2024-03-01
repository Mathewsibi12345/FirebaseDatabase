

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class update extends StatefulWidget {
  const update({Key? key}) : super(key: key);

  @override
  _updateState createState() => _updateState();
}

class _updateState extends State<update> {
  final CollectionReference employees =
      FirebaseFirestore.instance.collection('employees');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  File? _image; // Variable to store the picked image
  final picker = ImagePicker(); // Image picker instance
  bool _isLoading = false; // Flag to indicate loading state

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

  // Function to update employee details in Firestore
void updateEmployee(docId) async {
  setState(() {
    _isLoading = true; // Set loading state to true
  });

  final data = {
    'name': _nameController.text,
    'email': _emailController.text,
    'designation': _designationController.text,
  };

  // Upload image to Firebase Storage if an image is picked
  String? imageUrl;
  if (_image != null) {
    try {
      // Check if there is an existing image associated with the employee
      final existingImageUrl = await employees.doc(docId).get().then((doc) => doc['profile_image']);
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        // Delete existing image
        await FirebaseStorage.instance.refFromURL(existingImageUrl).delete();
      }

      // Upload new image
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        imageUrl = await storageReference.getDownloadURL();
        data['profile_image'] = imageUrl!;
      });
    } catch (error) {
      print('Error uploading image: $error');
      // Handle error while uploading image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading image. Please try again.'),
        ),
      );
      setState(() {
        _isLoading = false; // Set loading state to false
      });
      return;
    }
  }

  // Update the document in Firestore with the new data
  employees.doc(docId).update(data).then((value) {
    // Navigate back to the previous screen
    Navigator.pop(context);
  }).catchError((error) {
    // Handle error while updating employee details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update employee: $error'),
      ),
    );
  }).whenComplete(() {
    setState(() {
      _isLoading = false; // Set loading state to false
    });
  });
}



  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _nameController.text = args['name'];
    _emailController.text = args['email'];
    _designationController.text = args['designation'];
    final docId = args['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Employee'),
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
                //This is called the cascade operator (...)
                // It allows you to perform a sequence of operations on an object
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
                onPressed: _isLoading ? null : () => updateEmployee(docId),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                child: _isLoading
                    ? CircularProgressIndicator() // Show loading indicator if loading
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
