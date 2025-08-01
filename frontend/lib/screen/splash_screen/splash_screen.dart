import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), (){
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-image.png',
              width: width * 0.5,
              height: height * 0.3,
              fit: BoxFit.cover,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Welcome to AI FIT',
              style: TextStyle(fontSize: Dimensions.font24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );;
  }
}

