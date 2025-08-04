import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/apis/auth/auth.dart'; // Your auth service
import 'package:frontend/utils/dimensions.dart';
import 'package:frontend/widgets/snackbar_utils.dart';
import 'package:go_router/go_router.dart';
import '../login_screen/login_screen.dart'; // Your login screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Auth authService = Auth();



  /// Handles user logout.
  Future<void> _logout() async {
    try {
      await authService.logout();
      context.go('/login');
    } catch (e) {
        SnackbarUtils.showError(context, e.toString());

    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          // Disable logout button while another operation is in progress
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: Text("data"),
      ),
    );
  }
}
