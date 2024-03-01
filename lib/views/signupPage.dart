

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_employment_managment_system/controllers/auth.dart';
import 'package:flutter_application_employment_managment_system/views/base.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
   // Text editing controllers for handling user input
final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false; // Variable to track loading state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUP"),
        backgroundColor: Colors.red,
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if password and confirm password match
                if (_passwordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password and Confirm Password do not match.'),
                    ),
                  );
                  return;
                }
else {
      setState(() {
        _loading = true;
      });

      final message = await AuthService().registration(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text, // Pass confirm password
      );

      setState(() {
        _loading = false;
      });

      if (message!.contains('Success')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home(email: ' ',)),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  },
  child: _loading
    ? const CircularProgressIndicator()
    : const Text('Create Account'),
),
  
          ],
        ),
      ),
    );
  }
}
