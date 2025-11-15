import 'package:flutter/material.dart';

class AccuracyIndicator extends StatelessWidget {
  final bool isUsingGps;
  final bool radarAvailable;
  final int rainChance;

  const AccuracyIndicator({
    super.key,
    required this.isUsingGps,
    required this.radarAvailable,
    required this.rainChance,
  });

  int _calculateAccuracyScore() {
    int score = 0;
    if (isUsingGps) score += 40;
    if (radarAvailable) score += 40;
    if (rainChance >= 70) {
      score += 20;
    } else if (rainChance >= 40) {
      score += 10;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccuracyDashboard(
              isUsingGps: isUsingGps,
              radarAvailable: radarAvailable,
              rainChance: rainChance,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Accuracy Check",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // GPS accuracy
              Row(
                children: [
                  Icon(
                    isUsingGps ? Icons.gps_fixed : Icons.gps_off,
                    color: isUsingGps ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUsingGps
                          ? "GPS Location: Accurate"
                          : "Fallback Location: Slightly Less Accurate",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Radar accuracy
              Row(
                children: [
                  Icon(
                    radarAvailable ? Icons.cloud : Icons.cloud_off,
                    color: radarAvailable ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      radarAvailable
                          ? "IMD Radar: Live Rain Data Accurate"
                          : "Radar Unavailable: Using Forecast Only",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Forecast confidence
              Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rainChance >= 70
                          ? "Forecast: High accuracy (Rain likely)"
                          : rainChance >= 30
                          ? "Forecast: Medium accuracy"
                          : "Forecast: Low rain probability",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildAccuracyScore(),

              const SizedBox(height: 8),
              const Text(
                'Tap for detailed dashboard',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generate a simple accuracy score
  Widget _buildAccuracyScore() {
    int score = _calculateAccuracyScore();

    Color color = score >= 80
        ? Colors.green
        : score >= 50
        ? Colors.orange
        : Colors.red;

    return Row(
      children: [
        Icon(Icons.speed, color: color),
        const SizedBox(width: 8),
        Text(
          "Accuracy Score: $score%",
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

// Full-screen Accuracy Dashboard
class AccuracyDashboard extends StatefulWidget {
  final bool isUsingGps;
  final bool radarAvailable;
  final int rainChance;

  const AccuracyDashboard({
    super.key,
    required this.isUsingGps,
    required this.radarAvailable,
    required this.rainChance,
  });

  @override
  State<AccuracyDashboard> createState() => _AccuracyDashboardState();
}

class _AccuracyDashboardState extends State<AccuracyDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _accuracyScore = 0;

  @override
  void initState() {
    super.initState();
    _calculateScore();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: _accuracyScore.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _calculateScore() {
    int score = 0;
    if (widget.isUsingGps) score += 40;
    if (widget.radarAvailable) score += 40;
    if (widget.rainChance >= 70) {
      score += 20;
    } else if (widget.rainChance >= 40) {
      score += 10;
    }
    _accuracyScore = score;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Highly Accurate';
    if (score >= 50) return 'Medium Accuracy';
    return 'Lower Accuracy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accuracy Dashboard'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Animated circular accuracy score
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(_accuracyScore).withValues(alpha: 0.7),
                        _getScoreColor(_accuracyScore),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreColor(
                          _accuracyScore,
                        ).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_animation.value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getScoreLabel(_accuracyScore),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Detailed breakdown
            _buildDetailCard(
              'GPS Location',
              widget.isUsingGps ? 'Active & Accurate' : 'Using Fallback',
              widget.isUsingGps ? Icons.gps_fixed : Icons.gps_off,
              widget.isUsingGps ? Colors.green : Colors.red,
              widget.isUsingGps ? 40 : 0,
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              'IMD Radar',
              widget.radarAvailable
                  ? 'Live Data Available'
                  : 'Offline - Forecast Only',
              widget.radarAvailable ? Icons.radar : Icons.radar_outlined,
              widget.radarAvailable ? Colors.blue : Colors.grey,
              widget.radarAvailable ? 40 : 0,
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              'Forecast Model',
              widget.rainChance >= 70
                  ? 'High Confidence'
                  : widget.rainChance >= 40
                  ? 'Medium Confidence'
                  : 'Low Rain Probability',
              Icons.analytics,
              Colors.indigo,
              widget.rainChance >= 70
                  ? 20
                  : widget.rainChance >= 40
                  ? 10
                  : 0,
            ),
            const SizedBox(height: 30),

            // Rain alert section
            _buildRainAlertSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    String status,
    IconData icon,
    Color color,
    int points,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '+$points%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRainAlertSection() {
    String alertLevel;
    IconData alertIcon;
    Color alertColor;
    String alertMessage;

    if (_accuracyScore >= 80 && widget.rainChance >= 70) {
      alertLevel = 'HIGH ACCURACY RAIN ALERT';
      alertIcon = Icons.warning_amber;
      alertColor = Colors.red;
      alertMessage =
          'Rain is highly likely (${widget.rainChance}%). Data is very accurate. Carry umbrella!';
    } else if (_accuracyScore >= 50 && widget.rainChance >= 50) {
      alertLevel = 'MODERATE RAIN ALERT';
      alertIcon = Icons.info_outline;
      alertColor = Colors.orange;
      alertMessage =
          'Rain is possible (${widget.rainChance}%). Medium confidence forecast.';
    } else if (widget.rainChance >= 40) {
      alertLevel = 'LOW RAIN ALERT';
      alertIcon = Icons.cloud_outlined;
      alertColor = Colors.blue;
      alertMessage =
          'Some rain possible (${widget.rainChance}%). Check updates.';
    } else {
      alertLevel = 'NO RAIN ALERT';
      alertIcon = Icons.wb_sunny;
      alertColor = Colors.green;
      alertMessage =
          'Low rain probability (${widget.rainChance}%). Should be clear!';
    }

    return Card(
      elevation: 4,
      color: alertColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(alertIcon, size: 48, color: alertColor),
            const SizedBox(height: 12),
            Text(
              alertLevel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: alertColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              alertMessage,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Alert System Explanation',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• Accuracy ≥80% + Rain ≥70% = HIGH ALERT\n'
              '• Accuracy ≥50% + Rain ≥50% = MODERATE ALERT\n'
              '• Rain ≥40% = LOW ALERT\n'
              '• Rain <40% = NO ALERT',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
