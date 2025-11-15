import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/open_meteo_service.dart';
import '../services/imd_radar_service.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/today_rain_card.dart';
import '../widgets/weekly_forecast_list.dart';
import '../widgets/radar_view.dart';
import '../widgets/hourly_temperature_chart.dart';
import '../widgets/accuracy_indicator.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final OpenMeteoService _weatherService = OpenMeteoService();
  final ImdRadarService _radarService = ImdRadarService();
  final CacheService _cacheService = CacheService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  bool _isUsingGPS = false;
  bool _isLoadingFromCache = false;
  String _errorMessage = '';

  Map<String, dynamic>? _weatherData;
  Map<String, double>? _location;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await _notificationService.requestPermissions();
  }

  Future<void> _loadWeatherData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isLoadingFromCache = false;
    });

    try {
      // Try loading from cache first
      if (!forceRefresh) {
        final cachedData = await _cacheService.getCachedWeatherData();
        final cachedLocation = await _cacheService.getCachedLocation();

        if (cachedData != null && cachedLocation != null) {
          setState(() {
            _weatherData = cachedData;
            _location = cachedLocation;
            _isUsingGPS =
                _location!['lat'] != _locationService.fallbackLat ||
                _location!['lon'] != _locationService.fallbackLon;
            _isLoading = false;
            _isLoadingFromCache = true;
          });

          // Show cache info
          final cacheAge = await _cacheService.getCacheAgeMinutes();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Loaded from cache ($cacheAge min ago)'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

      // Get fresh location
      _location = await _locationService.getCurrentLocation();

      // Check if using GPS or fallback
      _isUsingGPS =
          _location!['lat'] != _locationService.fallbackLat ||
          _location!['lon'] != _locationService.fallbackLon;

      // Fetch weather data
      _weatherData = await _weatherService.getCompleteWeatherData();

      // Cache the data
      await _cacheService.cacheWeatherData(_weatherData!);
      await _cacheService.cacheLocation(_location!);

      // Send notifications
      final rainChance = _weatherData!['today']['rain_chance'] as int;
      final hourlyRain = List<double>.from(
        _weatherData!['today']['hourly_rain'].map((e) => (e ?? 0.0).toDouble()),
      );
      final totalRain = hourlyRain.reduce((a, b) => a + b);

      await _notificationService.checkAndNotify(
        rainChance: rainChance,
        totalRain: totalRain,
      );

      setState(() {
        _isLoading = false;
        _isLoadingFromCache = false;
      });

      if (mounted && forceRefresh) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weather data refreshed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load weather data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oli Weather'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Auto-location indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(_isUsingGPS ? Icons.gps_fixed : Icons.gps_off, size: 20),
                const SizedBox(width: 4),
                Text(
                  _isUsingGPS ? 'GPS' : 'Manual',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadWeatherData(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            tooltip: 'About App',
          ),
        ],
      ),
      body: _isLoading && !_isLoadingFromCache
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadWeatherData(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWeatherData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current temperature card
                    _buildCurrentTemperatureCard(),
                    const SizedBox(height: 16),

                    // Accuracy Indicator
                    AccuracyIndicator(
                      isUsingGps: _isUsingGPS,
                      radarAvailable: true,
                      rainChance: _weatherData!['today']['rain_chance'],
                    ),
                    const SizedBox(height: 16),

                    // Today rain card
                    TodayRainCard(
                      rainChance: _weatherData!['today']['rain_chance'],
                      hourlyRain: List<double>.from(
                        _weatherData!['today']['hourly_rain'].map(
                          (e) => (e ?? 0.0).toDouble(),
                        ),
                      ),
                      hourlyTimes: List<String>.from(
                        _weatherData!['today']['hourly_times'],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hourly Temperature Chart
                    HourlyTemperatureChart(
                      hourlyTemperatures: List<double>.from(
                        _weatherData!['today']['hourly_temperature'].map(
                          (e) => (e ?? 0.0).toDouble(),
                        ),
                      ),
                      hourlyTimes: List<String>.from(
                        _weatherData!['today']['hourly_times'],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weekly forecast
                    const Text(
                      '7-Day Forecast',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WeeklyForecastList(
                      forecast: List<Map<String, dynamic>>.from(
                        _weatherData!['extended_forecast'].take(7).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 16-Day Extended Forecast
                    const Text(
                      '16-Day Extended Forecast',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WeeklyForecastList(
                      forecast: List<Map<String, dynamic>>.from(
                        _weatherData!['extended_forecast'],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // IMD Radar
                    const Text(
                      'IMD Radar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadarView(radarService: _radarService),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentTemperatureCard() {
    final current = _weatherData!['current'];
    final temperature = current['temperature'];

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Current Temperature',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '${temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rain: ${current['rain'].toStringAsFixed(1)} mm',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              _isUsingGPS
                  ? 'Location: GPS (${_location!['lat']!.toStringAsFixed(4)}, ${_location!['lon']!.toStringAsFixed(4)})'
                  : 'Location: Fallback (${_location!['lat']!.toStringAsFixed(4)}, ${_location!['lon']!.toStringAsFixed(4)})',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
