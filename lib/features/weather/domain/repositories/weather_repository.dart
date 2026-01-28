import '../entities/weather.dart';


abstract class WeatherRepository {

  //input field users can type cityName
  Future<Weather> getWeather(String cityName);

}