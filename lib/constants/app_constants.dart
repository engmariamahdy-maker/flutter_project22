import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'My Tasks';
  static const double borderRadiusSm = 12.0;
  static const double borderRadiusMd = 16.0;
  static const double borderRadiusLg = 20.0;
  static const double borderRadiusXl = 24.0;

  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(4.0);
  static const EdgeInsets paddingSm = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMd = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLg = EdgeInsets.all(24.0);
  static const EdgeInsets paddingXl = EdgeInsets.all(32.0);

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const List<String> priorityLabels = ['منخفضة', 'متوسطة', 'عالية'];
}
