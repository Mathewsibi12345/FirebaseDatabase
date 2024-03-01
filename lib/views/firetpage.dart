
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Homeems extends StatefulWidget {
  const Homeems({Key? key}) : super(key: key);

  @override
  State<Homeems> createState() => _HomeemsState();
}

class _HomeemsState extends State<Homeems> {
  final CollectionReference employees =
      FirebaseFirestore.instance.collection('employees');
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> deleteEmployee(String docId, String? imageUrl) async {
    // Delete document from Firestore
    await employees.doc(docId).delete();
    
    // Delete image from Firebase Storage if it exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await storage.refFromURL(imageUrl).delete();
    }
  }

  Future<void> showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: const Text('Do you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout action
                Navigator.pushReplacementNamed(context, '/'); // Navigate to HomePage
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () {
              showLogoutConfirmationDialog();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/AddEmployeePage");
        },
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
        stream: employees.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return const Center(
                child: Text("No Employee Found"),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot employee = documents[index];
                return ListTile(
                  title: Text("Employee ID: ${employee.id}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${employee['name']}"),
                      Text("Email: ${employee['email']}"),
                      Text("Designation: ${employee['designation']}"),
                      // Display the image using the URL stored in Firestore
                      if (employee['profile_image'] != null &&
                          employee['profile_image'].isNotEmpty)
                        Image.network(
                          employee['profile_image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      else
                        Placeholder(
                          fallbackHeight: 100,
                          fallbackWidth: 100,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/update", arguments: {
                            'name': employee['name'],
                            'email': employee['email'],
                            'designation': employee['designation'],
                            "id": employee.id,
                          });
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          deleteEmployee(employee.id, employee['profile_image']);
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      )
                    ],
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

