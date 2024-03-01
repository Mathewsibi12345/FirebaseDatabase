import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmployeeImagePage extends StatefulWidget {
  final String employeeId;

  EmployeeImagePage({required this.employeeId});

  @override
  _EmployeeImagePageState createState() => _EmployeeImagePageState();
}

class _EmployeeImagePageState extends State<EmployeeImagePage> {
  late Future<String?> imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = _getImageUrl();
  }

  Future<String?> _getImageUrl() async {
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images/${widget.employeeId}.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error retrieving image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Image'),
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: imageUrl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading the image');
            } else if (snapshot.hasData) {
              return Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            } else {
              return Placeholder();
            }
          },
        ),
      ),
    );
  }
}
