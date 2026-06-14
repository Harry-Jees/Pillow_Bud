import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;
}

extension StringExtension on String {
  bool get isEmailValid => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);
}
