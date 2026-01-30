import '../entities/weather.dart';
import 'package:dio/dio.dart'; //

abstract class WeatherRepository {

  //input field users can type cityName
  Future<Weather> getWeather(String cityName, CancelToken cancelToken);

}