import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sky_cast_weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:sky_cast_weather/features/weather/presentation/screens/Weather_display_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_cast_weather/features/weather/presentation/providers/weather_provider.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/entities/weather.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final WeatherRepositoryImpl _repository = WeatherRepositoryImpl();

  List<Map<String, String>> _searchResults = [];
  String? _errorMessage;
  Timer? _debounce;
  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaultLocation();
    });
  }

  Future<void> _initializeDefaultLocation() async {
    setState(() => _isLocationLoading = true);

    final cityName = await LocationService().getCurrentCity();

    if (mounted) {
      setState(() => _isLocationLoading = false);
    }

    if (cityName.isNotEmpty) {

      ref.read(localWeatherProvider.notifier).fetchWeather(cityName);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    try {
      final results = await _repository.searchCities(query);
      setState(() {
        _searchResults = results;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _errorMessage = e.toString();
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
          _errorMessage = null;
        });
        return;
      }

      try {
        final results = await _repository.searchCities(query);
        setState(() {
          _searchResults = results;
          _errorMessage = null;
        });
      } catch (e) {
        setState(() {
          _searchResults = [];
          _errorMessage = e.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToWeather(String city) {
    if (city.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WeatherDisplayScreen(cityName: city.trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);

    final localWeatherState = ref.watch(localWeatherProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Sky Cast",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A3673), Color(0xFF2962FF)],
            ),
          ),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Search Bar Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Enter city name...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.grey),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _errorMessage = null;
                                _searchResults = [];
                              });
                              _onSearchChanged('');
                            },
                          )
                              : null,
                        ),
                        onChanged: (userTypewords) {
                          _onSearchChanged(userTypewords);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      setState(() => _isLocationLoading = true);

                      final cityName = await LocationService().getCurrentCity();

                      if (mounted) {
                        setState(() => _isLocationLoading = false);
                      }

                      if (cityName.isNotEmpty) {

                        ref.read(localWeatherProvider.notifier).fetchWeather(cityName);
                        _controller.clear();
                      }
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1A3673), Color(0xFF2962FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2962FF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        // ✅ FIX 2: Removed logic check for _isLocationLoading
                        // It now always shows "Search"
                        child: Text(
                          "Search",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              localWeatherState.maybeWhen(
                data: (weather) => _buildMiniWeatherCard(weather),
                loading: () => const Center(child: CircularProgressIndicator()),
                orElse: () => _buildLocationShortcut(),
              ),

              const SizedBox(height: 20),

              // Search Results List
              Expanded(
                child: _errorMessage != null
                    ? _buildErrorView()
                    : _buildSearchResultsList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationShortcut() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () async {
          setState(() => _isLocationLoading = true);

          final cityName = await LocationService().getCurrentCity();

          if (mounted) {
            setState(() => _isLocationLoading = false);
          }

          if (cityName.isNotEmpty) {
            // ✅ FIX 1: Update localWeatherProvider
            ref.read(localWeatherProvider.notifier).fetchWeather(cityName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Location access is required for this feature."),
                action: SnackBarAction(
                  label: "Settings",
                  onPressed: () => Geolocator.openAppSettings(),
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue),
              const SizedBox(width: 15),
              _isLocationLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                "Use Current Location",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMiniWeatherCard(Weather weather) {
    return GestureDetector(
      onTap: () => _navigateToWeather(weather.cityName),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE58CFF), Color(0xFF2962FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.condition,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Text("Now", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text(
                  "${weather.currentTemp.round()}°",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weather.cityName,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.wb_sunny, color: Colors.yellow, size: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 60, color: Colors.blueGrey),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          TextButton.icon(
            onPressed: () => _performSearch(_controller.text),
            icon: const Icon(Icons.refresh, color: Color(0xFF2962FF)),
            label: const Text("Try again"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2962FF),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3673), Color(0xFF2962FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_outlined, color: Colors.white, size: 24),
            ),
            title: Text(
              city['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white60, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    city['admin1']!.isEmpty
                        ? city['country']!
                        : "${city['admin1']}, ${city['country']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            onTap: () => _navigateToWeather(city['name']!),
          ),
        );
      },
    );
  }
}