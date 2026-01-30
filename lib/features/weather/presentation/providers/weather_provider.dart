import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather.dart';


// 1. Repository Provider
final weatherRepositoryProvider = Provider((ref) => WeatherRepositoryImpl());

// 2. Unit Provider (true = Celsius, false = Fahrenheit)
final unitProvider = StateProvider<bool>((ref) => true);

// 3. Weather State Notifier Provider
final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Weather>>((ref) {
  final repo = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repo);
});

class WeatherNotifier extends StateNotifier<AsyncValue<Weather>> {
  final WeatherRepositoryImpl _repository;
  WeatherNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchWeather(String city) async {
    state = const AsyncValue.loading();
    try {
      final weather = await _repository.getWeather(city);
      state = AsyncValue.data(weather); // Success: wraps data in AsyncValue
    } catch (e, stack) {
      state = AsyncValue.error(e, stack); // Error: wraps error for the UI
    }
  }
}