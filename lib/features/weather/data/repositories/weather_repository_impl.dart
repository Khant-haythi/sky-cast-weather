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
      // THIS IS THE NEW ERROR HANDLING LOGIC
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode;
        if (status == 404) throw 'City not found. Please try another name.';
        throw 'Server error: $status. Please try again later.';
      }
      throw 'Something went wrong. Please try again.';
    } catch (e) {
      // Catch any other unexpected errors (like parsing issues)
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
      // THIS IS THE NEW ERROR HANDLING LOGIC
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode;
        if (status == 404) throw 'City not found. Please try another name.';
        throw 'Server error: $status. Please try again later.';
      }
      throw 'Something went wrong. Please try again.';
    } catch (e) {
      // Catch any other unexpected errors (like parsing issues)
      throw e.toString();
    }
  }
  }
