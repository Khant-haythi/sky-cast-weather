import 'package:flutter/material.dart';

class WeatherThemeMapper {
  static List<Color> getGradient(int code) {

    if (code == 0 || code == 1) { // Clear/Sunny
      return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
    } else if (code >= 2 && code <= 3) { // Cloudy
      return [const Color(0xFF89f7fe), const Color(0xFF66a6ff)];
    } else if (code >= 51 && code <= 67 || code >= 80 && code <= 82) { // Rain
      return [const Color(0xFF203a43), const Color(0xFF2c5364)];
    } else if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) { // Snow
      return [const Color(0xFFE6E9F0), const Color(0xFFEEF1F5)];
    }

    return [const Color(0xFF1A3673), const Color(0xFF2962FF)];
  }

  static bool isLightSource(int code) {

    return (code >= 71 && code <= 77) || (code >= 85 && code <= 86);
  }
}
