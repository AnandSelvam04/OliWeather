import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class OpenMeteoService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';
  final LocationService _locationService = LocationService();

  /// Fetch current weather data
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Get current location
      Map<String, double> location = await _locationService
          .getCurrentLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Build API URL for current weather
      final url = Uri.parse(
        '$baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,precipitation,rain&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['current']['temperature_2m'],
          'precipitation': data['current']['precipitation'] ?? 0.0,
          'rain': data['current']['rain'] ?? 0.0,
          'time': data['current']['time'],
          'timezone': data['timezone'],
        };
      } else {
        throw Exception(
          'Failed to load current weather: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching current weather: $e');
      rethrow;
    }
  }

  /// Fetch today's rain chance and hourly data
  Future<Map<String, dynamic>> getTodayRainData() async {
    try {
      // Get current location
      Map<String, double> location = await _locationService
          .getCurrentLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Build API URL for today's hourly data
      final url = Uri.parse(
        '$baseUrl?latitude=$lat&longitude=$lon&hourly=precipitation_probability,precipitation,rain&forecast_days=1&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hourly = data['hourly'];

        // Calculate average rain chance for today
        List<dynamic> rainProbability =
            hourly['precipitation_probability'] ?? [];
        double avgRainChance = 0.0;
        if (rainProbability.isNotEmpty) {
          avgRainChance =
              rainProbability.reduce((a, b) => a + b) / rainProbability.length;
        }

        // Calculate total rain amount for today
        List<dynamic> rainAmounts = hourly['rain'] ?? [];
        double totalRain = 0.0;
        if (rainAmounts.isNotEmpty) {
          totalRain = rainAmounts.reduce((a, b) => (a ?? 0.0) + (b ?? 0.0));
        }

        return {
          'rain_chance': avgRainChance.round(),
          'total_rain_mm': totalRain,
          'hourly_times': hourly['time'],
          'hourly_rain': hourly['rain'],
          'hourly_precipitation_probability':
              hourly['precipitation_probability'],
        };
      } else {
        throw Exception(
          'Failed to load today rain data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching today rain data: $e');
      rethrow;
    }
  }

  /// Fetch 7-16 day forecast with rain and temperature
  Future<List<Map<String, dynamic>>> getExtendedForecast() async {
    try {
      // Get current location
      Map<String, double> location = await _locationService
          .getCurrentLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Build API URL for 16-day forecast
      final url = Uri.parse(
        '$baseUrl?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_probability_max&forecast_days=16&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];

        List<Map<String, dynamic>> forecast = [];

        // Start from day 7 (index 6) to day 16 (index 15)
        for (int i = 6; i < 16 && i < daily['time'].length; i++) {
          forecast.add({
            'date': daily['time'][i],
            'max_temp': daily['temperature_2m_max'][i],
            'min_temp': daily['temperature_2m_min'][i],
            'rain_mm': daily['rain_sum'][i] ?? 0.0,
            'precipitation_mm': daily['precipitation_sum'][i] ?? 0.0,
            'rain_chance': daily['precipitation_probability_max'][i] ?? 0,
          });
        }

        return forecast;
      } else {
        throw Exception(
          'Failed to load extended forecast: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching extended forecast: $e');
      rethrow;
    }
  }

  /// Fetch complete weather data (current + hourly + daily for 16 days)
  Future<Map<String, dynamic>> getCompleteWeatherData() async {
    try {
      // Get current location
      Map<String, double> location = await _locationService
          .getCurrentLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Build comprehensive API URL
      final url = Uri.parse(
        '$baseUrl?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,precipitation,rain'
        '&hourly=precipitation_probability,precipitation,rain,temperature_2m'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_probability_max'
        '&forecast_days=16&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Process today's hourly data (first 24 hours)
        final hourly = data['hourly'];
        List<dynamic> todayHourlyRain = (hourly['rain'] as List)
            .take(24)
            .toList();
        List<dynamic> todayHourlyTemp = (hourly['temperature_2m'] as List)
            .take(24)
            .toList();
        List<dynamic> todayHourlyTimes = (hourly['time'] as List)
            .take(24)
            .toList();

        // Calculate today's rain chance
        List<dynamic> todayRainProb =
            (hourly['precipitation_probability'] as List).take(24).toList();
        double avgRainChance = 0.0;
        if (todayRainProb.isNotEmpty) {
          avgRainChance =
              todayRainProb.reduce((a, b) => (a ?? 0) + (b ?? 0)) /
              todayRainProb.length;
        }

        // Process 7-16 day forecast
        final daily = data['daily'];
        List<Map<String, dynamic>> extendedForecast = [];
        for (int i = 6; i < 16 && i < daily['time'].length; i++) {
          extendedForecast.add({
            'date': daily['time'][i],
            'max_temp': daily['temperature_2m_max'][i],
            'min_temp': daily['temperature_2m_min'][i],
            'rain_mm': daily['rain_sum'][i] ?? 0.0,
            'precipitation_mm': daily['precipitation_sum'][i] ?? 0.0,
            'rain_chance': daily['precipitation_probability_max'][i] ?? 0,
          });
        }

        return {
          'current': {
            'temperature': data['current']['temperature_2m'],
            'precipitation': data['current']['precipitation'] ?? 0.0,
            'rain': data['current']['rain'] ?? 0.0,
            'time': data['current']['time'],
          },
          'today': {
            'rain_chance': avgRainChance.round(),
            'hourly_rain': todayHourlyRain,
            'hourly_temperature': todayHourlyTemp,
            'hourly_times': todayHourlyTimes,
          },
          'extended_forecast': extendedForecast,
          'location': {'latitude': lat, 'longitude': lon},
          'timezone': data['timezone'],
        };
      } else {
        throw Exception(
          'Failed to load complete weather data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching complete weather data: $e');
      rethrow;
    }
  }

  /// Fetch daily forecast for the next 7 days (0-6)
  Future<List<Map<String, dynamic>>> getWeeklyForecast() async {
    try {
      // Get current location
      Map<String, double> location = await _locationService
          .getCurrentLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Build API URL for 7-day forecast
      final url = Uri.parse(
        '$baseUrl?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_probability_max&forecast_days=7&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];

        List<Map<String, dynamic>> forecast = [];

        for (int i = 0; i < 7 && i < daily['time'].length; i++) {
          forecast.add({
            'date': daily['time'][i],
            'max_temp': daily['temperature_2m_max'][i],
            'min_temp': daily['temperature_2m_min'][i],
            'rain_mm': daily['rain_sum'][i] ?? 0.0,
            'precipitation_mm': daily['precipitation_sum'][i] ?? 0.0,
            'rain_chance': daily['precipitation_probability_max'][i] ?? 0,
          });
        }

        return forecast;
      } else {
        throw Exception(
          'Failed to load weekly forecast: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching weekly forecast: $e');
      rethrow;
    }
  }
}
