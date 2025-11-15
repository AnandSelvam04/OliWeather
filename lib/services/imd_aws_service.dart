import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImdAwsService {
  // IMD AWS data URL for Madurai
  static const String maduraiAwsUrl =
      'https://nwp.imd.gov.in/AWS/Madurai_AWS_Data.json';

  /// Fetch Madurai AWS data
  Future<Map<String, dynamic>> getMaduraiAwsData() async {
    try {
      final response = await http.get(Uri.parse(maduraiAwsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception(
          'Failed to load Madurai AWS data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching Madurai AWS data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Parse AWS station data from the response
  List<Map<String, dynamic>> parseAwsStations(Map<String, dynamic> data) {
    try {
      List<Map<String, dynamic>> stations = [];

      if (data['data'] != null && data['data'] is List) {
        for (var station in data['data']) {
          stations.add({
            'station_name': station['station_name'] ?? 'Unknown',
            'temperature': station['temperature'] ?? 0.0,
            'humidity': station['humidity'] ?? 0.0,
            'rainfall': station['rainfall'] ?? 0.0,
            'wind_speed': station['wind_speed'] ?? 0.0,
            'wind_direction': station['wind_direction'] ?? 'N/A',
            'pressure': station['pressure'] ?? 0.0,
            'timestamp': station['timestamp'] ?? '',
          });
        }
      }

      return stations;
    } catch (e) {
      debugPrint('Error parsing AWS stations: $e');
      return [];
    }
  }

  /// Get specific station data by name
  Future<Map<String, dynamic>?> getStationByName(String stationName) async {
    try {
      final awsData = await getMaduraiAwsData();

      if (awsData['success'] == true) {
        final stations = parseAwsStations(awsData);

        return stations.firstWhere(
          (station) => station['station_name']
              .toString()
              .toLowerCase()
              .contains(stationName.toLowerCase()),
          orElse: () => {},
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error getting station by name: $e');
      return null;
    }
  }

  /// Check if AWS data is available
  Future<bool> isAwsDataAvailable() async {
    try {
      final response = await http.head(Uri.parse(maduraiAwsUrl));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error checking AWS data availability: $e');
      return false;
    }
  }
}
