import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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


      if (geoResponse.data['results'] == null) {
        throw Exception('City not found');
      }

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
          'hourly': 'temperature_2m,weather_code',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'forecast_days': 7,
          'timezone': 'auto',
        },
      );

      //pass data to the factory constructor
      return WeatherModel.fromOpenMeteo(
          weatherResponse.data,
          correctCityName,
          country
      );
    } on DioException catch (e) {
      throw _handleDioError(e); // Clean calling
    } catch (e) {
      throw e.toString();
    }
  }


  Future<List<Map<String, String>>> searchCities(String query) async {
    try {
      final response = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': query,
          'count': 20,
          'language': 'en',
          'format': 'json'
        },
      );

      final results = response.data['results'];
      if (results == null || (results as List).isEmpty) {
        throw 'City not found. Please try a different name.';
      }

      final List<Map<String, String>> uniqueCities = [];
      final Set<String> seen = {};

      for (var city in results) {
        final name = city['name']?.toString() ?? '';
        final region = city['admin1']?.toString() ?? '';
        final country = city['country']?.toString() ?? '';

        final uniqueKey = "$name-$region-$country".toLowerCase();

        if (!seen.contains(uniqueKey)) {
          seen.add(uniqueKey);
          uniqueCities.add({
            'name': name,
            'country': country,
            'admin1': region,
          });
        }


        if (uniqueCities.length >= 5) break;
      }

      return uniqueCities;
    } on DioException catch (e) {
      throw _handleDioError(e); // Clean calling
    } catch (e) {
      throw e.toString();
    }
  }

String _handleDioError(DioException e) {
  if (e.response != null) {
    final status = e.response?.statusCode;
    if (status == 404) return 'Request Error (404): API link not found.';
    if (status != null && status >= 500) return 'Server Error ($status): The service is down.';
    return 'Unexpected Error ($status): Please try again.';
  } else {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    return 'Network Error: Could not reach server.';
  }
}
}