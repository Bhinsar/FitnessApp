import 'package:flutter/material.dart';
import '../utils/Dimensions.dart';
import 'dart:math';

class Skeleten extends StatelessWidget {
  final double? height;
  final double? width;

  const Skeleten({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        // Use a light, semi-transparent color for the skeleton
        color: Colors.white.withOpacity(0.13),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
