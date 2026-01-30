import '../../domain/entities/weather.dart';


class WeatherModel extends Weather {

  // 2. The Constructor MUST pass data to 'super' (The Parent)
  WeatherModel({
    required super.cityName,
    required super.country,
    required super.currentTemp,
    required super.condition,
    required super.conditionIconId,
    required super.dailyForecasts,
    required super.detailedForecasts

  });


  // factory constructor to turn messy json data into weatherModel object
  factory WeatherModel.fromOpenMeteo(
      Map<String, dynamic> json,
      String city,
      String country,
      ) {

    final current = json['current'] ?? {};
    final daily = json['daily'] ?? {};

    List<DailyForecast> forecasts = [];
    for (int i = 0; i < 5; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(daily['time'][i]),
        maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
        minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
        condition: _mapWmoCodeToString(daily['weather_code'][i]),
        iconId: daily['weather_code'][i].toString(),
          weatherCode: daily['weather_code'][i] as int,
      ));
    }

    final hourly = json['hourly'] ?? {};
    final List<double> allTemps = List<double>.from(hourly['temperature_2m']);
    final List<int> allCodes = List<int>.from(hourly['weather_code']);

    List<DayDetailedForecast> detailedList = [];

    for (int i = 0; i < 5; i++) {
      int dayOffset = i * 24;

      detailedList.add(DayDetailedForecast(
        date: DateTime.now().add(Duration(days: i)),
        slots: [
          HourlySlot(time: "9 AM", temp: allTemps[dayOffset + 9], weatherCode: allCodes[dayOffset + 9]),
          HourlySlot(time: "12 PM", temp: allTemps[dayOffset + 12], weatherCode: allCodes[dayOffset + 12]),
          HourlySlot(time: "3 PM", temp: allTemps[dayOffset + 15], weatherCode: allCodes[dayOffset + 15]),
          HourlySlot(time: "6 PM", temp: allTemps[dayOffset + 18], weatherCode: allCodes[dayOffset + 18]),
        ],
      ));
    }

    return WeatherModel(
      cityName: city,
      country: country,
      currentTemp: (current['temperature_2m'] as num).toDouble(),
      condition: _mapWmoCodeToString(current['weather_code']),
      conditionIconId: current['weather_code'].toString(),
      dailyForecasts: forecasts,
      detailedForecasts: detailedList,
    );
  }

  //function that covert WMO code into the description
  static String _mapWmoCodeToString(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Cloudy';
      case 45: case 48: return 'Foggy';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rainy';
      case 80: case 81: case 82: return 'Showers';
      case 71: case 73: case 75: case 77: return 'Snowy';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Clear sky';
    }
  }
}