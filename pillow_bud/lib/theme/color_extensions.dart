import 'package:flutter/material.dart';

/// Theme color utilities
extension ColorOpacityHelper on Color {
  /// Convenient alpha helper that maps cleanly to native withValues
  Color withAlphaFraction(double fraction) {
    return withValues(alpha: fraction);
  }
}
