import 'package:dio/dio.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final Dio _dio = Dio();
  @override
  Future<Weather> getWeather(String cityName) async {
    try {

      // Find the City (Geocoding API)
      final geoResponse = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': cityName,
          'count': 1,
          'language': 'en',
          'format': 'json'
        },
      );

      // Check if city exists
      if (geoResponse.data['results'] == null) {
        throw Exception('City not found');
      }

      // Extract the data we need for the next step
      final location = geoResponse.data['results'][0];
      final double lat = location['latitude'];
      final double lng = location['longitude'];
      final String correctCityName = location['name'];
      final String country = location['country'] ?? 'Unknown';

      // Get the Weather (Forecast API) using lat and lng
      final weatherResponse = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': 'temperature_2m,weather_code',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
        },
      );

      //pass data to the factory constructor
      return WeatherModel.fromOpenMeteo(
          weatherResponse.data,
          correctCityName,
          country
      );

    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }
}