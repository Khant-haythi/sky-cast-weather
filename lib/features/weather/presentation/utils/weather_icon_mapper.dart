import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconMapper {
  static IconData getIcon(int code) {
    // 0: Clear sky
    if (code == 0) return WeatherIcons.day_sunny;

    // 1-3: Main clouds (Partly to mainly cloudy)
    if (code >= 1 && code <= 3) return WeatherIcons.cloud;

    // 45, 48: Fog and depositing rime fog
    // Use a specific fog icon instead of general clouds
    if (code == 45 || code == 48) return WeatherIcons.fog;

    // 51-67: Drizzle and Rain (not snowing)
    if (code >= 51 && code <= 67) return WeatherIcons.rain;

    // 71-77: Snow (slight to heavy)
    if (code >= 71 && code <= 77) return WeatherIcons.snow;

    // 80-82: Rain Showers
    if (code >= 80 && code <= 82) return WeatherIcons.showers;

    // 85-86: Snow Showers
    if (code == 85 || code == 86) return WeatherIcons.snow;

    // 95-99: Thunderstorm
    if (code >= 95) return WeatherIcons.thunderstorm;

    // Default fallback
    return WeatherIcons.na;
  }
}