//
class Weather {
  final String cityName;
  final String country;
  final double currentTemp;
  final String condition;
  final String conditionIconId;
  final List<DailyForecast> dailyForecasts;
  final List<DayDetailedForecast> detailedForecasts;

  Weather({
    required this.cityName,
    required this.country,
    required this.currentTemp,
    required this.condition,
    required this.conditionIconId,
    required this.dailyForecasts,
    required this.detailedForecasts,
  });

  double get currentTempF => (currentTemp * 9 / 5) + 32;


}


class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String iconId;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconId,
    required this.weatherCode,
  });

  double get temp => maxTemp;
  double get maxTempF => (maxTemp * 9 / 5) + 32;
  double get minTempF => (minTemp * 9 / 5) + 32;

}

class DayDetailedForecast {
  final DateTime date;
  final List<HourlySlot> slots;

  DayDetailedForecast({required this.date, required this.slots});
}

class HourlySlot {
  final String time;
  final double temp;
  final int weatherCode;

  HourlySlot({required this.time, required this.temp, required this.weatherCode});
}