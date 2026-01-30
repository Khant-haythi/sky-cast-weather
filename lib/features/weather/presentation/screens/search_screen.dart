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
  String? _errorMessage;
  Timer? _debounce;
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false; // Fix: should be false if empty
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Start the spinner inside the button
      // Note: DON'T set _errorMessage = null here if you want
      // the error text to stay visible while it's spinning.
    });

    try {
      final results = await _repository.searchCities(query);
      setState(() {
        _searchResults = results;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _errorMessage = e.toString();
        _isLoading = false; // Stop the spinner so the "Try again" icon returns
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
          _errorMessage = e.toString(); // Catch errors even while typing
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
                    onTap: () {

                      FocusScope.of(context).unfocus();
                      _performSearch(_controller.text);
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
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              //The search List
              Expanded(
                  child: _isLoading
                        ? const Center(
                        child: CircularProgressIndicator(
                        color: Color(0xFF2962FF),
                  ),
                )
                 : _errorMessage != null
                        ? Center(
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
                        TextButton(
                          onPressed: _isLoading ? null : () => _performSearch(_controller.text),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2962FF),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // This prevents the overflow
                            children: [
                              if (_isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2962FF),
                                  ),
                                )
                              else
                                const Icon(Icons.refresh, size: 20),

                              const SizedBox(width: 8), // Space between icon/spinner and text

                              Text(
                                _isLoading ? "Retrying..." : "Try again",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                  : ListView.builder(
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