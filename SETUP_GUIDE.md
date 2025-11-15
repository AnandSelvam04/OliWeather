# 🚀 Oli Weather - Complete Setup Guide

## ✅ Current Status
Your app is **production-ready** with:
- ✅ All dependencies installed (12 packages)
- ✅ Android permissions configured
- ✅ Services layer complete (7 services)
- ✅ UI layer complete (5 widgets + 1 screen)
- ✅ Dark mode with persistence
- ✅ Accuracy dashboard
- ✅ Rain notifications
- ✅ Offline caching (30 min)
- ✅ No compilation errors

---

## 📋 Quick Start (5 Steps)

### 1. **Install Dependencies** ✅ DONE
```bash
flutter pub get
```

### 2. **Prepare App Icon & Splash Screen**
Create these folders and add images:
```
oli_weather/
├── assets/
│   ├── icon/
│   │   └── app_icon.png      # 512x512px (your logo)
│   └── splash/
│       └── splash_icon.png   # 512x512px (splash logo)
```

**Optional:** If you don't provide images, default Flutter icons will be used.

### 3. **Generate App Icon & Splash Screen**
```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 4. **Connect Android Device**
Enable USB Debugging on your Android phone:
- Settings → About Phone → Tap "Build Number" 7 times
- Settings → Developer Options → Enable USB Debugging
- Connect via USB cable

Verify connection:
```bash
flutter devices
```

### 5. **Run the App**
```bash
flutter run
```

---

## 📱 First Launch Checklist

When app launches for the first time:

1. **Grant Location Permission** - Tap "Allow" when prompted
2. **Grant Notification Permission** - Tap "Allow" for weather alerts
3. **Wait for Data Load** - First load fetches live weather data
4. **Test Features:**
   - ✅ View current weather and rain forecast
   - ✅ Scroll to see 7-day and 16-day forecasts
   - ✅ Tap accuracy score to see dashboard
   - ✅ Tap radar card to view Chennai IMD radar
   - ✅ Toggle dark mode (moon icon top-right)
   - ✅ Pull down to refresh weather data

---

## 🔧 Troubleshooting

### **"Permissions denied" Error**
**Solution:** Manually grant permissions in phone settings:
```
Settings → Apps → Oli Weather → Permissions
→ Enable Location (Allow all the time)
→ Enable Notifications
```

### **"API Error" or "No Data"**
**Cause:** Internet connection issue or API rate limit  
**Solution:** 
- Check internet connection
- Wait 1 minute (API rate limit)
- Pull down to refresh

### **Radar Images Not Loading**
**Cause:** IMD server may be temporarily unavailable  
**Solution:** 
- Check internet connection
- Try switching radar types (3-dot menu)
- IMD servers update every 15 minutes

### **Location Stuck at Trichy**
**Cause:** GPS permission not granted  
**Solution:**
- Grant location permission when prompted
- Ensure location services enabled on phone
- App will fall back to Trichy (10.10501, 78.11336) if GPS fails

---

## 🎨 Customization Guide

### Change Fallback Location
Edit `lib/services/location_service.dart` line 26:
```dart
return {
  'lat': 10.10501,  // Change to your latitude
  'lon': 78.11336,  // Change to your longitude
};
```

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml` line 3:
```xml
android:label="Your App Name"
```

### Adjust Cache Duration
Edit `lib/services/cache_service.dart` line 4:
```dart
static const Duration _cacheDuration = Duration(minutes: 30); // Change 30
```

### Modify Alert Thresholds
Edit `lib/services/notification_service.dart`:
```dart
if (rainChance >= 70.0) {  // Line 50 - High rain threshold
if (rainChance >= 40.0) {  // Line 58 - Umbrella threshold
if (totalRain >= 10.0) {   // Line 66 - Heavy rain threshold
```

### Change Morning Reminder Time
Edit `lib/services/notification_service.dart` line 173:
```dart
scheduledDate = scheduledDate.add(Duration(hours: 8)); // Change 8 to your hour (0-23)
```

---

## 🏗️ Building for Release

### Generate Release APK
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Generate App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Bundle location: `build/app/outputs/bundle/release/app-release.aab`

### Sign the App (Required for Play Store)
Follow official guide: https://docs.flutter.dev/deployment/android#signing-the-app

---

## 📦 Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| http | 1.2.2 | API calls (Open-Meteo, IMD) |
| geolocator | 13.0.4 | GPS location detection |
| permission_handler | 11.4.0 | Permission requests |
| intl | 0.20.2 | Date formatting |
| fl_chart | 1.1.1 | Temperature charts |
| shared_preferences | 2.5.3 | Cache & theme storage |
| provider | 6.1.5+1 | State management |
| flutter_local_notifications | 19.5.0 | Rain alerts |
| timezone | 0.10.1 | Notification scheduling |
| flutter_launcher_icons | 0.14.4 | Icon generation |
| flutter_native_splash | 2.4.7 | Splash screen |

---

## 🌍 Data Sources

1. **Open-Meteo API** - Weather forecast (free, no API key)
   - Endpoint: `https://api.open-meteo.com/v1/forecast`
   - Data: Temperature, rain, wind, weather codes

2. **IMD Radar** - Chennai station live radar images
   - Endpoint: `https://nwp.imd.gov.in/blf/blf_aws_ra/`
   - Updates: Every 15 minutes

3. **Madurai AWS** - Automated Weather Station JSON
   - Endpoint: IMD AWS data feed
   - Data: Real-time station readings

---

## 🎯 Accuracy System

**Total Score: 0-100%**

| Component | Points | Description |
|-----------|--------|-------------|
| GPS | 40 | Location accuracy (0=fallback, 40=GPS) |
| Radar | 40 | IMD radar availability (0=offline, 40=online) |
| Rain Forecast | 0-20 | Weather API confidence (0-20 based on rain %) |

**Alert Levels:**
- 🔴 **HIGH** (≥80% accuracy + ≥70% rain chance)
- 🟡 **MODERATE** (≥50% accuracy + ≥50% rain chance)
- 🔵 **LOW** (≥40% rain chance)
- ⚪ **NO ALERT** (Below thresholds)

---

## 📞 Support

**For issues or questions:**
1. Check `README.md` for detailed documentation
2. Review `CHANGELOG.md` for feature list
3. Check Flutter logs: `flutter logs`
4. Verify all permissions granted in phone settings

---

## 🚀 Next Steps (Optional Enhancements)

- [ ] Add custom app icon (512x512px PNG)
- [ ] Add custom splash screen (512x512px PNG)
- [ ] Test on multiple Android devices
- [ ] Add more locations (modify location service)
- [ ] Add more radar stations (see CHANGELOG v1.1.0 plans)
- [ ] Deploy to Google Play Store
- [ ] Add iOS support (requires Mac)

---

**🎉 Your Oli Weather app is ready to use! Run `flutter run` to get started.**
