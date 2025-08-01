import 'package:flutter/material.dart';
import 'package:frontend/apis/auth/auth.dart'; // Import your auth service
import '../login_screen/login_screen.dart'; // Import login screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Auth authService = Auth();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Call the logout method
              await authService.logout();

              // Navigate back to the LoginScreen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false, // This predicate removes all routes
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome! You are logged in.'),
      ),
    );
  }
}