import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<double> hourlyTemperatures;
  final List<String> hourlyTimes;

  const HourlyTemperatureChart({
    super.key,
    required this.hourlyTemperatures,
    required this.hourlyTimes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hourly Temperature',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 5,
                    verticalInterval: 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= hourlyTimes.length) {
                            return const Text('');
                          }
                          final time = hourlyTimes[value.toInt()];
                          final hour = time.split('T')[1].substring(0, 2);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${hour}h',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
                  minX: 0,
                  maxX: (hourlyTemperatures.length - 1).toDouble(),
                  minY: _getMinTemp() - 2,
                  maxY: _getMaxTemp() + 2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade400],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.orange,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade200.withValues(alpha: 0.3),
                            Colors.red.shade200.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final time = hourlyTimes[spot.x.toInt()];
                          final hour = time.split('T')[1].substring(0, 5);
                          return LineTooltipItem(
                            '$hour\n${spot.y.toStringAsFixed(1)}°C',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTempStat(
                  'Max',
                  '${_getMaxTemp().toStringAsFixed(1)}°C',
                  Colors.red,
                ),
                _buildTempStat(
                  'Min',
                  '${_getMinTemp().toStringAsFixed(1)}°C',
                  Colors.blue,
                ),
                _buildTempStat(
                  'Avg',
                  '${_getAvgTemp().toStringAsFixed(1)}°C',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return List.generate(
      hourlyTemperatures.length,
      (index) => FlSpot(index.toDouble(), hourlyTemperatures[index]),
    );
  }

  double _getMaxTemp() {
    return hourlyTemperatures.reduce((a, b) => a > b ? a : b);
  }

  double _getMinTemp() {
    return hourlyTemperatures.reduce((a, b) => a < b ? a : b);
  }

  double _getAvgTemp() {
    final sum = hourlyTemperatures.reduce((a, b) => a + b);
    return sum / hourlyTemperatures.length;
  }

  Widget _buildTempStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
