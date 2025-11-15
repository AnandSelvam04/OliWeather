import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About Oli Weather'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.blue.shade900, Colors.blue.shade700]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wb_sunny,
                      size: 80,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Oli Weather',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Your Personal Weather Companion',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Features',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.thermostat,
                    title: 'Real-Time Weather',
                    description:
                        'Current temperature, 24-hour forecast, and 16-day extended predictions',
                    color: Colors.orange,
                  ),
                  _buildFeatureCard(
                    icon: Icons.location_on,
                    title: 'GPS Location',
                    description:
                        'Automatic location detection for Palamedu/Trichy region with fallback support',
                    color: Colors.green,
                  ),
                  _buildFeatureCard(
                    icon: Icons.radar,
                    title: 'IMD Radar',
                    description:
                        'Live Chennai radar images, composite views, satellite & rainfall data',
                    color: Colors.purple,
                  ),
                  _buildFeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Smart Alerts',
                    description:
                        'Accuracy-based rain alerts, umbrella reminders, and morning weather updates',
                    color: Colors.red,
                  ),
                  _buildFeatureCard(
                    icon: Icons.speed,
                    title: 'Accuracy Dashboard',
                    description:
                        'Live accuracy scoring (GPS + Radar + Forecast) with animated visualization',
                    color: Colors.blue,
                  ),
                  _buildFeatureCard(
                    icon: Icons.cloud_download,
                    title: 'Offline Cache',
                    description:
                        '30-minute smart caching for seamless experience even without internet',
                    color: Colors.teal,
                  ),
                  _buildFeatureCard(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    description:
                        'Beautiful light and dark themes with persistent settings',
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 30),

                  // Data Sources
                  const Text(
                    '🌐 Data Sources',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Open-Meteo API',
                    description:
                        'Free weather forecasting API providing temperature, precipitation, wind, and weather codes',
                    icon: Icons.api,
                  ),
                  _buildInfoCard(
                    title: 'IMD (India Meteorological Department)',
                    description:
                        'Official radar images from Chennai station and Madurai AWS real-time data',
                    icon: Icons.public,
                  ),

                  const SizedBox(height: 30),

                  // Accuracy System
                  const Text(
                    '🎯 Accuracy System',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAccuracyRow(
                            'GPS Location',
                            '+40 points',
                            Colors.green,
                          ),
                          const Divider(),
                          _buildAccuracyRow(
                            'Radar Availability',
                            '+40 points',
                            Colors.blue,
                          ),
                          const Divider(),
                          _buildAccuracyRow(
                            'Rain Confidence',
                            '+0 to +20 points',
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Total Score: 0-100%\n🟢 80-100% Excellent | 🟠 50-79% Good | 🔴 0-49% Fair',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Alert Thresholds
                  const Text(
                    '🔔 Alert Thresholds',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildAlertCard(
                    '🔴 HIGH RAIN ALERT',
                    '≥80% accuracy + ≥70% rain chance',
                    Colors.red,
                  ),
                  _buildAlertCard(
                    '🟡 MODERATE ALERT',
                    '≥50% accuracy + ≥50% rain chance',
                    Colors.orange,
                  ),
                  _buildAlertCard(
                    '🔵 LOW ALERT',
                    '≥40% rain chance',
                    Colors.blue,
                  ),
                  _buildAlertCard(
                    '⚪ NO ALERT',
                    'Below alert thresholds',
                    Colors.grey,
                  ),

                  const SizedBox(height: 30),

                  // Technologies
                  const Text(
                    '🛠️ Built With',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip('Flutter'),
                      _buildTechChip('Dart'),
                      _buildTechChip('Provider'),
                      _buildTechChip('HTTP'),
                      _buildTechChip('Geolocator'),
                      _buildTechChip('FL Chart'),
                      _buildTechChip('SharedPreferences'),
                      _buildTechChip('Local Notifications'),
                      _buildTechChip('Material Design 3'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Developer Info
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.code, size: 48, color: Colors.blue),
                          const SizedBox(height: 12),
                          const Text(
                            'Developed for Palamedu/Trichy Region',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fallback Coordinates: 10.10501°N, 78.11336°E',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '© 2024 Oli Weather\nFor Educational & Personal Use',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
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
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildAccuracyRow(String label, String points, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            points,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(String title, String condition, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.circle, color: color, size: 16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(condition, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }
}
