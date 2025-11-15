import 'package:flutter/material.dart';

class TodayRainCard extends StatelessWidget {
  final int rainChance;
  final List<double> hourlyRain;
  final List<String> hourlyTimes;

  const TodayRainCard({
    super.key,
    required this.rainChance,
    required this.hourlyRain,
    required this.hourlyTimes,
  });

  @override
  Widget build(BuildContext context) {
    final totalRain = hourlyRain.reduce((a, b) => a + b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Rain',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRainStat(
                  'Rain Chance',
                  '$rainChance%',
                  Icons.water_drop,
                  Colors.blue,
                ),
                _buildRainStat(
                  'Total Rain',
                  '${totalRain.toStringAsFixed(1)} mm',
                  Icons.opacity,
                  Colors.lightBlue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Hourly Rain Graph',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildHourlyRainGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildRainStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyRainGraph() {
    final maxRain = hourlyRain.reduce((a, b) => a > b ? a : b);
    final graphHeight = 120.0;

    return SizedBox(
      height: graphHeight + 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyRain.length,
        itemBuilder: (context, index) {
          final rain = hourlyRain[index];
          final time = hourlyTimes[index];
          final hour = time.split('T')[1].substring(0, 5); // Extract HH:MM
          final barHeight = maxRain > 0 ? (rain / maxRain) * graphHeight : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Rain value
                Text(
                  rain > 0 ? rain.toStringAsFixed(1) : '',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                // Bar
                Container(
                  width: 24,
                  height: barHeight.clamp(2, graphHeight),
                  decoration: BoxDecoration(
                    color: rain > 0 ? Colors.blue : Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Time label
                Text(hour, style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }
}
