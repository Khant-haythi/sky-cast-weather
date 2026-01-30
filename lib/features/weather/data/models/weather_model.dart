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
          weatherCode: daily['weather_code'][i] as int,
      ));
    }

    // Inside WeatherModel.fromOpenMeteo(Map<String, dynamic> json...)
    final hourly = json['hourly'];
    final List<double> allTemps = List<double>.from(hourly['temperature_2m']);
    final List<int> allCodes = List<int>.from(hourly['weather_code']);

    List<DayDetailedForecast> detailedList = [];

// Loop for the next 5 days
    for (int i = 0; i < 5; i++) {
      int dayOffset = i * 24; // Calculate start of each day

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