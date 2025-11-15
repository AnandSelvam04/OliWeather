import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImdRadarService {
  // IMD Radar base URLs
  static const String radarBaseUrl = 'https://nwp.imd.gov.in/blf/blf_aws_ra/';

  // Chennai radar station
  static const String chennaiStationCode = 'CHN';
  static const String chennaiStationName = 'Chennai';

  /// Get the Chennai radar image URL
  String getChennaiRadarImageUrl() {
    return '${radarBaseUrl}CHN.gif';
  }

  /// Get composite radar image (all India)
  String getCompositeRadarImageUrl() {
    return '${radarBaseUrl}COMP.gif';
  }

  /// Get satellite image URL
  String getSatelliteImageUrl() {
    return 'https://nwp.imd.gov.in/satellite/3Dasiasec_ir1.jpg';
  }

  /// Get rainfall radar overlay URL
  String getRainfallRadarUrl() {
    return '${radarBaseUrl}COMP_RF.gif';
  }

  /// Check if Chennai radar image is available
  Future<bool> isRadarImageAvailable() async {
    try {
      final url = getChennaiRadarImageUrl();
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error checking radar image availability: $e');
      return false;
    }
  }

  /// Get Chennai radar data summary
  Future<Map<String, dynamic>> getChennaiRadarData() async {
    try {
      String radarUrl = getChennaiRadarImageUrl();
      bool isAvailable = await isRadarImageAvailable();

      return {
        'station_code': chennaiStationCode,
        'station_name': chennaiStationName,
        'radar_url': radarUrl,
        'is_available': isAvailable,
        'composite_url': getCompositeRadarImageUrl(),
        'satellite_url': getSatelliteImageUrl(),
        'rainfall_url': getRainfallRadarUrl(),
      };
    } catch (e) {
      debugPrint('Error getting radar data: $e');
      rethrow;
    }
  }
}
