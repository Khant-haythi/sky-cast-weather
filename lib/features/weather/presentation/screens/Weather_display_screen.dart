import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sky_cast_weather/features/weather/presentation/screens/weather_detail_screen.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather.dart';
import '../utils/weather_icon_mapper.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherDisplayScreen extends StatefulWidget {
  final String cityName;
  const WeatherDisplayScreen({super.key, required this.cityName});

  @override
  State<WeatherDisplayScreen> createState() => _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends State<WeatherDisplayScreen> {
  final WeatherRepositoryImpl _repository = WeatherRepositoryImpl();
  late Future<Weather> _weatherFuture;
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() {
    setState(() {
      _weatherFuture = _repository.getWeather(widget.cityName);
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
    return Scaffold(
      body: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: const BoxDecoration(color: Color(0xFF1A3673)),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              color: const Color(0xFF1A3673),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white70, size: 80),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadWeather, // Your retry logic
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final weather = snapshot.data!;

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A3673), Color(0xFF2962FF)],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _loadWeather(),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildTopBar(weather),
                    const SizedBox(height: 20),
                    _buildCurrentWeather(weather),
                    const SizedBox(height: 20),
                    _buildForecastContainer(weather),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(Weather weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "${weather.cityName}, ${weather.country}",
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
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
                style: const TextStyle(
                    color: Colors.white,
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

  Widget _buildCurrentWeather(Weather weather) {
    return Column(
      children: [
        Lottie.asset(
          WeatherAnimationMapper.getAnimation(weather.dailyForecasts[0].weatherCode),
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 5),
        Text(
          _isCelsius
              ? "${weather.currentTemp.round()}°C"
              : "${weather.currentTempF.round()}°F",
          style: const TextStyle(
              color: Colors.white, fontSize: 80, fontWeight: FontWeight.w200),
        ),
        Text(
          weather.condition,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 4),

        Text(
          _isCelsius
              ? "H: ${weather.dailyForecasts[0].maxTemp.round()}°  L: ${weather.dailyForecasts[0].minTemp.round()}°"
              : "H: ${weather.dailyForecasts[0].maxTempF.round()}°  L: ${weather.dailyForecasts[0].minTempF.round()}°",
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 5),

      ],
    );
  }


  Widget _buildForecastContainer(Weather weather) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text("5-day forecast",
                      style: TextStyle(color: Colors.white70)),
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
                child: const Text("More details ▶",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          ...weather.dailyForecasts.take(5)
              .map((f) => _buildForecastRow(f))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildForecastRow(DailyForecast forecast) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(_formatDate(forecast.date),
                style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          Text("${forecast.maxTemp.round()}°",
              style: const TextStyle(color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


}