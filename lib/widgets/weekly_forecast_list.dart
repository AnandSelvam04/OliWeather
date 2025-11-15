import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyForecastList extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const WeeklyForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: forecast.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final day = forecast[index];
          final date = DateTime.parse(day['date']);
          final dayName = DateFormat('EEE, MMM d').format(date);

          return ListTile(
            leading: _getWeatherIcon(day['rain_chance']),
            title: Text(
              dayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Rain: ${day['rain_mm'].toStringAsFixed(1)} mm • ${day['rain_chance']}%',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${day['max_temp'].toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${day['min_temp'].toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getWeatherIcon(int rainChance) {
    if (rainChance >= 70) {
      return const Icon(Icons.thunderstorm, color: Colors.purple, size: 32);
    } else if (rainChance >= 40) {
      return const Icon(Icons.water_drop, color: Colors.blue, size: 32);
    } else if (rainChance >= 20) {
      return const Icon(Icons.cloud, color: Colors.grey, size: 32);
    } else {
      return const Icon(Icons.wb_sunny, color: Colors.orange, size: 32);
    }
  }
}
