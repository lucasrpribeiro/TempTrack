import 'package:flutter/material.dart';

class ColorUtils {
  // Temperature color constants
  static const Color futureGray = Color(0xFF4A4A4A);
  static const Color belowZero = Color(0xFFFFFFFF);
  static const Color temp0to10 = Color(0xFFA8D5FF);
  static const Color temp11to20 = Color(0xFF6BB6FF);
  static const Color temp21to25 = Color(0xFF2E86DE);
  static const Color temp26to30 = Color(0xFFFFD93D);
  static const Color temp31to35 = Color(0xFFF4A300);
  static const Color temp36to37 = Color(0xFFFF8C42);
  static const Color temp38plus = Color(0xFFFF4757);

  static Color getColorForTemperature(double? temperature, bool isFuture) {
    if (isFuture || temperature == null) {
      return futureGray;
    }

    if (temperature < 0) return belowZero;
    if (temperature <= 10) return temp0to10;
    if (temperature <= 20) return temp11to20;
    if (temperature <= 25) return temp21to25;
    if (temperature <= 30) return temp26to30;
    if (temperature <= 35) return temp31to35;
    if (temperature <= 37) return temp36to37;
    return temp38plus;
  }

  static Color getBrighterColor(Color color) {
    return Color.lerp(color, Colors.white, 0.2)!;
  }
}
