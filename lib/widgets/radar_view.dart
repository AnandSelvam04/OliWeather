import 'package:flutter/material.dart';
import '../services/imd_radar_service.dart';

class RadarView extends StatefulWidget {
  final ImdRadarService radarService;

  const RadarView({super.key, required this.radarService});

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView> {
  String _selectedRadarType = 'chennai';
  final bool _isLoading = false;
  String? _errorMessage;

  String get _currentRadarUrl {
    switch (_selectedRadarType) {
      case 'chennai':
        return widget.radarService.getChennaiRadarImageUrl();
      case 'composite':
        return widget.radarService.getCompositeRadarImageUrl();
      case 'satellite':
        return widget.radarService.getSatelliteImageUrl();
      case 'rainfall':
        return widget.radarService.getRainfallRadarUrl();
      default:
        return widget.radarService.getChennaiRadarImageUrl();
    }
  }

  String get _currentRadarTitle {
    switch (_selectedRadarType) {
      case 'chennai':
        return 'Chennai Radar';
      case 'composite':
        return 'India Composite';
      case 'satellite':
        return 'Satellite Image';
      case 'rainfall':
        return 'Rainfall Radar';
      default:
        return 'Radar View';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentRadarTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        setState(() {
                          _selectedRadarType = value;
                          _errorMessage = null;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'chennai',
                          child: Text('Chennai Radar'),
                        ),
                        const PopupMenuItem(
                          value: 'composite',
                          child: Text('India Composite'),
                        ),
                        const PopupMenuItem(
                          value: 'satellite',
                          child: Text('Satellite Image'),
                        ),
                        const PopupMenuItem(
                          value: 'rainfall',
                          child: Text('Rainfall Radar'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'IMD Real-time Radar',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey.shade200,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                : Image.network(
                    _currentRadarUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Failed to load radar image',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last updated: ${_formatTime(DateTime.now())}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {});
                  },
                  tooltip: 'Refresh radar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
