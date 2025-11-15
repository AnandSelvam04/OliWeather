# 🌦️ Oli Weather App

A professional Flutter weather application with advanced features including GPS location, IMD radar, rain alerts, offline caching, and dark mode.

## ✨ Features

### 🌡️ Weather Data
- **Current Temperature** - Real-time temperature with gradient display
- **Hourly Temperature Chart** - Interactive 24-hour temperature graph
- **Hourly Rain Graph** - Bar chart showing rain probability
- **7-Day Forecast** - Detailed weekly weather outlook
- **16-Day Extended Forecast** - Long-term weather planning

### 📍 Location & Accuracy
- **GPS Location** - Automatic detection (Palamedu/Trichy)
- **Accuracy Dashboard** - Animated accuracy score (0-100%)
- **Smart Alerts** - Accuracy-based rain notifications
- **Fallback Coordinates** - (10.10501, 78.11336)

### 🌧️ Rain Alerts
- **High Rain Alert** (≥70% chance)
- **Umbrella Reminder** (≥40% chance)
- **Heavy Rain Alert** (≥10mm)
- **Morning Reminders** (8 AM daily)

### 🌐 IMD Radar
- Chennai Radar, Composite, Satellite, Rainfall views
- Real-time rain visualization
- Auto-refresh capability

### 💾 Advanced Features
- **Offline Caching** - 30-minute smart cache
- **Dark Mode** - Beautiful light/dark themes
- **Pull-to-Refresh** - Instant updates
- **Material Design 3** - Modern UI

## 🚀 Quick Start

```bash
flutter pub get
flutter run
```

## 📦 Key Dependencies

```yaml
http, geolocator, permission_handler, intl
flutter_local_notifications, fl_chart
shared_preferences, provider
```

## 🎯 Accuracy System

- **GPS**: +40 points
- **Radar**: +40 points  
- **High Rain Confidence**: +20 points
- **Score**: 🟢80-100% | 🟠50-79% | 🔴0-49%

## 📱 Permissions

✅ Location, Internet, Notifications, Vibrate, Schedule Alarms

## 🌐 Data Sources

- **Open-Meteo API** - Weather forecasts
- **IMD** - Radar & Madurai AWS data

## 📂 Structure

```
lib/
├── main.dart
├── providers/theme_provider.dart
├── screens/home_screen.dart
├── services/
│   ├── location_service.dart
│   ├── open_meteo_service.dart
│   ├── imd_radar_service.dart
│   ├── notification_service.dart
│   └── cache_service.dart
└── widgets/
    ├── accuracy_indicator.dart
    ├── hourly_temperature_chart.dart
    ├── today_rain_card.dart
    ├── weekly_forecast_list.dart
    └── radar_view.dart
```

## 🔧 Configuration

Edit `location_service.dart` for fallback coordinates.
Edit `cache_service.dart` for cache duration (default: 30 min).
Edit `notification_service.dart` for alert times (default: 8 AM).

## 📄 License

Educational purposes. Weather data: Open-Meteo & IMD.

---

**Version**: 1.0.0 | **Platform**: Android | **Region**: Palamedu/Trichy
