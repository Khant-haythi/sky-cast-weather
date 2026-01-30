import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather.dart';

final weatherRepositoryProvider = Provider((ref) => WeatherRepositoryImpl());

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Weather>>((ref) {
  final repo = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repo);
});

final localWeatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Weather>>((ref) {
  final repo = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repo);
});

class WeatherNotifier extends StateNotifier<AsyncValue<Weather>> {
  final WeatherRepositoryImpl _repository;
  CancelToken? _cancelToken;

  WeatherNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchWeather(String city) async {

    _cancelToken?.cancel();

    _cancelToken = CancelToken();

    state = const AsyncValue.loading();

    try {

      final weather = await _repository.getWeather(city, _cancelToken!);

      if (mounted) {
        state = AsyncValue.data(weather);
      }
    } catch (e, stack) {
      if (e is DioException && CancelToken.isCancel(e)) {
        debugPrint("Old request cancelled successfully");
        return;
      }

      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}


