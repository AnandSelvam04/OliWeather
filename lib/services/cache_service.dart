import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _weatherDataKey = 'cached_weather_data';
  static const String _timestampKey = 'cached_timestamp';
  static const String _locationKey = 'cached_location';

  // Cache duration: 30 minutes
  static const Duration cacheDuration = Duration(minutes: 30);

  /// Save weather data to cache
  Future<void> cacheWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(weatherData);
      await prefs.setString(_weatherDataKey, jsonString);
      await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
      debugPrint('Weather data cached successfully');
    } catch (e) {
      debugPrint('Error caching weather data: $e');
    }
  }

  /// Save location to cache
  Future<void> cacheLocation(Map<String, double> location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(location);
      await prefs.setString(_locationKey, jsonString);
      debugPrint('Location cached successfully');
    } catch (e) {
      debugPrint('Error caching location: $e');
    }
  }

  /// Get cached weather data
  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_weatherDataKey);

      if (jsonString == null) {
        debugPrint('No cached weather data found');
        return null;
      }

      // Check if cache is still valid
      if (!await isCacheValid()) {
        debugPrint('Cache expired');
        return null;
      }

      final data = json.decode(jsonString) as Map<String, dynamic>;
      debugPrint('Loaded weather data from cache');
      return data;
    } catch (e) {
      debugPrint('Error loading cached weather data: $e');
      return null;
    }
  }

  /// Get cached location
  Future<Map<String, double>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_locationKey);

      if (jsonString == null) {
        return null;
      }

      final data = json.decode(jsonString);
      return {'lat': data['lat'] as double, 'lon': data['lon'] as double};
    } catch (e) {
      debugPrint('Error loading cached location: $e');
      return null;
    }
  }

  /// Check if cache is still valid
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_timestampKey);

      if (timestampString == null) {
        return false;
      }

      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < cacheDuration;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }

  /// Get cache age in minutes
  Future<int?> getCacheAgeMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_timestampKey);

      if (timestampString == null) {
        return null;
      }

      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference.inMinutes;
    } catch (e) {
      debugPrint('Error getting cache age: $e');
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_weatherDataKey);
      await prefs.remove(_timestampKey);
      await prefs.remove(_locationKey);
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Check if cache exists
  Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_weatherDataKey);
    } catch (e) {
      debugPrint('Error checking cache: $e');
      return false;
    }
  }

  /// Get cached timestamp
  Future<DateTime?> getCachedTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_timestampKey);

      if (timestampString == null) {
        return null;
      }

      return DateTime.parse(timestampString);
    } catch (e) {
      debugPrint('Error getting cached timestamp: $e');
      return null;
    }
  }
}
