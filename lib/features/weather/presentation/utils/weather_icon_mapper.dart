import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconMapper {
  static IconData getIcon(int code) {

    if (code == 0) return WeatherIcons.day_sunny;

    if (code >= 1 && code <= 3) return WeatherIcons.cloud;

    if (code == 45 || code == 48) return WeatherIcons.fog;

    if (code >= 51 && code <= 67) return WeatherIcons.rain;

    if (code >= 71 && code <= 77) return WeatherIcons.snow;

    if (code >= 80 && code <= 82) return WeatherIcons.showers;

    if (code == 85 || code == 86) return WeatherIcons.snow;

    if (code >= 95) return WeatherIcons.thunderstorm;

    return WeatherIcons.na;
  }
}

class WeatherAnimationMapper {
  static String getAnimation(int code) {
    if (code == 0) return 'assets/sunny.json';
    if (code >= 1 && code <= 3) return 'assets/Weather-partly cloudy.json';
    if (code >= 51 && code <= 67) return 'assets/rainy icon.json';
    if (code >= 71 && code <= 86) return 'assets/Weather-snow.json';
    return 'assets/sunny.json';
  }
}