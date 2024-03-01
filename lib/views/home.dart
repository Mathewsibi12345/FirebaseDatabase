import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employment Management System"),
        backgroundColor: Colors.red,
      ),

     body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                  
                 
                  //print('Login button pressed');
                },
                child: const Text('SignUP'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () { 
                   Navigator.pushNamed(context, '/login');
                
                 // print('Signup button pressed');
                },
                child: const Text('Login'),
              ),
            ],
          ),
     ),
    );
  }
}
