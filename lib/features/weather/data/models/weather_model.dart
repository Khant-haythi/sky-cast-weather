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
  });


  // factory constructor to turn messy json data into weatherModel object
  factory WeatherModel.fromOpenMeteo(
      Map<String, dynamic> json,
      String city,
      String country,
      ) {
    final current = json['current'];
    final daily = json['daily'];

    List<DailyForecast> forecasts = [];
    for (int i = 0; i < 7; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(daily['time'][i]),
        maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
        minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
        condition: _mapWmoCodeToString(daily['weather_code'][i]),
        iconId: daily['weather_code'][i].toString(),
      ));
    }

    return WeatherModel(
      cityName: city,
      country: country,
      currentTemp: (current['temperature_2m'] as num).toDouble(),
      condition: _mapWmoCodeToString(current['weather_code']),
      conditionIconId: current['weather_code'].toString(),
      dailyForecasts: forecasts,
    );
  }

  //function that covert WMO code into the description
  static String _mapWmoCodeToString(int code) {
    if (code == 0) return "Clear Sky";
    if (code < 4) return "Cloudy";
    if (code < 50) return "Foggy";
    if (code < 70) return "Rainy";
    if (code < 80) return "Snowy";
    if (code < 85) return "Heavy Rain";
    if (code < 90) return "Snowy";
    return "Thunderstorm";
  }
}