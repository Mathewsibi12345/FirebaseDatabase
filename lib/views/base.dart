import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.email});
  final String email;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome !'),
      ),
    );
  }
}
