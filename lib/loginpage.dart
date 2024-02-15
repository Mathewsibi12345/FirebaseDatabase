
import 'package:flutter/material.dart';
import 'package:flutter_application_employment_managment_system/controllers/auth.dart';
import 'package:flutter_application_employment_managment_system/views/addemployeepage.dart';
import 'package:flutter_application_employment_managment_system/views/base.dart';
import 'package:flutter_application_employment_managment_system/views/signupPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
            ElevatedButton(
              onPressed: () async {
                // Set loading state to true when login button is pressed
                setState(() {
                  _loading = true;
                });

                // Call login method from AuthService
                final message = await AuthService().login(
                  email: _emailController.text,
                  password: _passwordController.text,
                );

                // Set loading state back to false after login attempt
                setState(() {
                  _loading = false;
                });

                // If login is successful, navigate to the Home screen
                if (message!.contains('Success')) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AddEmployeePage(),
                    ),
                  );
                }

                // Show a SnackBar with the login result message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              },
              child: _loading
                  ? const CircularProgressIndicator() // Show loading indicator if _loading is true
                  : const Text('Login'),
            ),
            const SizedBox(
              height: 30.0,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddUser(),
                  ),
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
