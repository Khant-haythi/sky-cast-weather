import '../entities/weather.dart';
import 'package:dio/dio.dart'; //

abstract class WeatherRepository {

  Future<Weather> getWeather(String cityName, CancelToken cancelToken);

}