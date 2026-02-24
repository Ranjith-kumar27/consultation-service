import 'package:flutter/material.dart';

class ResponsiveConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late Orientation orientation;

  // You can adjust these base dimensions based on your design (e.g., iPhone 14 Pro: 390x844)
  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  static void init(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    orientation = mediaQueryData.orientation;
  }
}

extension ResponsiveExtension on num {
  /// Responsive Height
  double get rh {
    return (this / ResponsiveConfig.baseHeight) * ResponsiveConfig.screenHeight;
  }

  /// Responsive Width
  double get rw {
    return (this / ResponsiveConfig.baseWidth) * ResponsiveConfig.screenWidth;
  }

  /// Responsive Text Size
  /// We'll use the width scale for text to ensure it scales uniformly,
  /// or we can use a slightly smarter approach.
  double get rt {
    // A common approach is using the width scale for font size.
    final scale = ResponsiveConfig.screenWidth / ResponsiveConfig.baseWidth;
    return this * scale;
  }

  /// Responsive Radius (similar to width)
  double get r {
    return rw;
  }
}
