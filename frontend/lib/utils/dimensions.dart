import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dimensions {
  // Reference dimensions (e.g., based on iPhone 12 Pro: 844x390)
  static const double _referenceHeight = 844.0;
  static const double _referenceWidth = 390.0;

  // Get screen dimensions dynamically using MediaQuery
  static double get screenHeight => MediaQuery.sizeOf(Get.context!).height;
  static double get screenWidth => MediaQuery.sizeOf(Get.context!).width;

  // Scale factor for responsiveness
  static double get heightScaleFactor => screenHeight / _referenceHeight;
  static double get widthScaleFactor => screenWidth / _referenceWidth;

  // Responsive height dimensions
  static double get height10 => screenHeight / 84.4 * heightScaleFactor;
  static double get height15 => screenHeight / 56.27 * heightScaleFactor;
  static double get height20 => screenHeight / 42.2 * heightScaleFactor;
  static double get height30 => screenHeight / 28.13 * heightScaleFactor;
  static double get height45 => screenHeight / 19.56 * heightScaleFactor;

  // Responsive width dimensions
  static double get width10 => screenWidth / 84.4 * widthScaleFactor;
  static double get width15 => screenWidth / 56.27 * widthScaleFactor;
  static double get width20 => screenWidth / 42.2 * widthScaleFactor;
  static double get width30 => screenWidth / 28.13 * widthScaleFactor;
  static double get width45 => screenWidth / 19.56 * widthScaleFactor;

  // Responsive font sizes
  static double get font10 => screenHeight / 84.4 * heightScaleFactor;
  static double get font12 => screenHeight / 70.33 * heightScaleFactor;
  static double get font15 => screenHeight / 56.27 * heightScaleFactor;
  static double get font16 => screenHeight / 52.75 * heightScaleFactor;
  static double get font18 => screenHeight / 46.89 * heightScaleFactor;
  static double get font20 => screenHeight / 42.2 * heightScaleFactor;
  static double get font24 => screenHeight / 35.17 * heightScaleFactor;
  static double get font26 => screenHeight / 32.46 * heightScaleFactor;

}