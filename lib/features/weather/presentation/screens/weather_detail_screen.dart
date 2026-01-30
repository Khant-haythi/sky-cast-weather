import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //
import 'package:sky_cast_weather/features/weather/domain/entities/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import '../utils/weather_icon_mapper.dart';

class WeatherDetailScreen extends StatelessWidget {
  final Weather weather;
  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A3673), Color(0xFF2962FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  itemCount: weather.detailedForecasts.length,
                  itemBuilder: (context, index) {
                    final day = weather.detailedForecasts[index];
                    return _buildDayCard(day);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(DayDetailedForecast day) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, MMM d').format(day.date),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: day.slots.map((slot) => _buildSlot(slot)).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildSlot(HourlySlot slot) {
    return Column(
      children: [
        Text(slot.time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        BoxedIcon(
          WeatherIconMapper.getIcon(slot.weatherCode),
          color: Colors.orangeAccent,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
            "${slot.temp.round()}°",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text("5-Day Detailed Forecast", style: TextStyle(color: Colors.white, fontSize: 20)),
      ],
    );
  }
}