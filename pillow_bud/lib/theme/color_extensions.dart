import 'package:flutter/material.dart';

extension ColorWithValuesExtension on Color {
  Color withValues({required double alpha}) {
    return withOpacity(alpha);
  }
}
