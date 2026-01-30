import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sky_cast_weather/features/weather/presentation/screens/weather_detail_screen.dart';
import '../../../../core/utils/weather_theme_mapper.dart';
import '../../domain/entities/weather.dart';
import '../utils/weather_icon_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_cast_weather/features/weather/presentation/providers/weather_provider.dart';

class WeatherDisplayScreen extends ConsumerStatefulWidget {
  final String cityName;
  const WeatherDisplayScreen({super.key, required this.cityName});

  @override
  ConsumerState<WeatherDisplayScreen> createState() => _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {

  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        ref.read(weatherProvider.notifier).fetchWeather(widget.cityName);
      }
    });
  }



  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return "Tomorrow";
    }
    return DateFormat('EEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      body: weatherState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (weather) {

          if (weather.dailyForecasts.isEmpty) {
            return const Center(child: Text("No forecast data available for this city."));
          }

          final int currentCode = weather.dailyForecasts[0].weatherCode;

          final textColor = WeatherThemeMapper.isLightSource(currentCode)
              ? Colors.black87
              : Colors.white;

          final dynamicColors = WeatherThemeMapper.getGradient(weather.dailyForecasts[0].weatherCode);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dynamicColors,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => ref.read(weatherProvider.notifier).fetchWeather(widget.cityName),
                child: ListView(
                  children: [
                    _buildTopBar(weather,textColor),
                    _buildCurrentWeather(weather,textColor),
                    _buildForecastContainer(weather,textColor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(Weather weather,Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "${weather.cityName}, ${weather.country}",
              style: TextStyle(
                  color: textColor, fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isCelsius = !_isCelsius;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _isCelsius ? "°C" : "°F",
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather,Color textColor) {
    final int todayCode = weather.dailyForecasts[0].weatherCode;
    return Column(
      children: [
        Lottie.asset(
          WeatherAnimationMapper.getAnimation(todayCode),
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 5),
        Text(
          _isCelsius
              ? "${weather.currentTemp.round()}°C"
              : "${weather.currentTempF.round()}°F",
          style: TextStyle(
              color: textColor, fontSize: 80, fontWeight: FontWeight.w200),
        ),
        Text(
          weather.condition,
          style:  TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 4),

        Text(
          _isCelsius
              ? "H: ${weather.dailyForecasts[0].maxTemp.round()}°  L: ${weather.dailyForecasts[0].minTemp.round()}°"
              : "H: ${weather.dailyForecasts[0].maxTempF.round()}°  L: ${weather.dailyForecasts[0].minTempF.round()}°",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        const SizedBox(height: 5),

      ],
    );
  }


  Widget _buildForecastContainer(Weather weather,Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: textColor, size: 18),
                  const SizedBox(width: 8),
                  Text("5-day forecast",
                      style: TextStyle(color: textColor)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeatherDetailScreen(weather: weather),
                    ),
                  );
                },
                child: Text("More details ▶",
                    style: TextStyle(color: textColor, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          ...weather.dailyForecasts.take(5)
              .map((f) => _buildForecastRow(f,textColor))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildForecastRow(DailyForecast forecast,Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(_formatDate(forecast.date),
                style: TextStyle(color: textColor, fontSize: 16)),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(
                    WeatherIconMapper.getIcon(forecast.weatherCode),
                    color: Colors.orangeAccent,
                    size: 22
                ),
                const SizedBox(width: 8),
                Text(forecast.condition,
                    style: TextStyle(color: textColor, fontSize: 14)),
              ],
            ),
          ),
          Text("${forecast.maxTemp.round()}°",
              style: TextStyle(color: textColor ,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


}