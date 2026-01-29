import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sky_cast_weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:sky_cast_weather/features/weather/presentation/screens/Weather_display_screen.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final WeatherRepositoryImpl _repository = WeatherRepositoryImpl();

  List<Map<String,String>>  _searchResults = [];
  Timer? _debounce;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    // Show the user that the app is working
    final results = await _repository.searchCities(query);

    setState(() {
      _searchResults = results;
    });
  }

  void _onSearchChanged(String query){
    if(_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), ()async {
      if(query.trim().isEmpty){
        setState(() => _searchResults=[]) ;
        return;
      }
      final results = await _repository.searchCities(query);

      setState(() {
        _searchResults = results;
      });
    });

  }

  void _navigateToWeather(String city) {
    if (city.trim().isNotEmpty) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDisplayScreen(cityName: city.trim())
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Sky Cast",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // 1. Vertical Gradient for AppBar
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
              const SizedBox(height: 10,),
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
                        // Trigger search logic
                        onSubmitted: (value) => _navigateToWeather(value),
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
                              _onSearchChanged('');
                              setState(() {});
                            },
                          )
                              : null,
                          // contentPadding: const EdgeInsets.only(bottom: 5),
                        ),
                        onChanged: (userTypewords) {
                          _onSearchChanged(userTypewords);
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _performSearch(_controller.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3673),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text("Search"),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              //The search List
              Expanded(
                  child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final city = _searchResults[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            // 1. Premium Blue-to-Purple Gradient
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1A3673), // Bright Blue
                                const Color(0xFF2962FF),                 // Deep Navy
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20), // Extra rounded for modern look
                            // 2. Subtle shadow for "Floating" effect
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            // 3. Thin border for "Glass" definition
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
                                    // Logic: Only show the comma if admin1 is not empty
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
                            onTap: () {
                              _navigateToWeather(city['name']!);
                            },
                          ),
                        );
                      }

                  ) )
            ],
          ),
        ),
      ),
    );
  }
}