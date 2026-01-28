//
class Weather {
  final String cityName;
  final String country;
  final double currentTemp;
  final String condition;
  final String conditionIconId;
  final List<DailyForecast> dailyForecasts;

  Weather({
    required this.cityName,
    required this.country,
    required this.currentTemp,
    required this.condition,
    required this.conditionIconId,
    required this.dailyForecasts,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String iconId;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconId,
  });

  double get temp => maxTemp;
}