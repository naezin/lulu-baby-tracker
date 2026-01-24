# 🎨 Lulu Widget Integration Setup Guide

This guide will help you complete the native integration for Lulu's intelligent home screen widgets.

## Overview

Lulu widgets provide three beautiful, glassmorphism-styled variants:
- **Small Widget (2×2)**: Next Sweet Spot countdown with circular progress
- **Medium Widget (4×2)**: Today's summary + next action with quick shortcuts
- **Lock Screen Widget (iOS)**: Minimal next feeding time

## Architecture

```
Flutter Layer
├── lib/data/services/widget_service.dart (Widget data management)
├── lib/presentation/screens/settings/widget_settings_screen.dart (User UI)
└── lib/main.dart (Deep linking handler)

iOS Native Layer
├── ios/LuluWidget/LuluWidget.swift (WidgetKit implementation)
└── ios/LuluWidget/Info.plist (Widget configuration)

Android Native Layer
├── android/.../LuluWidgetProvider.kt (AppWidget implementation)
├── android/.../res/layout/widget_*.xml (Widget layouts)
└── android/.../res/xml/lulu_widget_info.xml (Widget metadata)
```

---

## 📱 iOS Setup (WidgetKit)

### Step 1: Add Widget Extension to Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select **Widget Extension**
4. Product Name: `LuluWidget`
5. Language: **Swift**
6. **Uncheck** "Include Configuration Intent"
7. Click **Finish**
8. When prompted "Activate 'LuluWidget' scheme?", click **Activate**

### Step 2: Configure App Group

**Both the main app AND the widget extension need the same App Group to share data.**

#### For Main App (Runner):
1. Select **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → **App Groups**
4. Click **+** and add: `group.com.lulu.babytracker`
5. Check the box next to it

#### For Widget Extension (LuluWidget):
1. Select **LuluWidget** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → **App Groups**
4. Click **+** and add: `group.com.lulu.babytracker`
5. Check the box next to it

### Step 3: Replace Widget Code

1. Delete the auto-generated `LuluWidget.swift` file
2. Copy the code from `/ios/LuluWidget/LuluWidget.swift` (already created)
3. Add it to the **LuluWidget** target in Xcode

### Step 4: Update Info.plist

1. Open `ios/LuluWidget/Info.plist`
2. Ensure it matches the file we created (already created)
3. Verify `AppGroup` key is set to `group.com.lulu.babytracker`

### Step 5: Build and Test

```bash
# Clean build
flutter clean
flutter pub get

# Run on iOS
flutter run -d ios
```

**To test widgets:**
1. Long press on iOS home screen
2. Tap **+** in top left
3. Search for **Lulu**
4. Select widget size
5. Tap **Add Widget**

---

## 🤖 Android Setup (AppWidget)

### Step 1: Register Widget Provider in AndroidManifest.xml

**Location:** `android/app/src/main/AndroidManifest.xml`

Add this inside the `<application>` tag:

```xml
<receiver
    android:name=".LuluWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.lulu.babytracker.SLEEP" />
        <action android:name="com.lulu.babytracker.FEEDING" />
        <action android:name="com.lulu.babytracker.DIAPER" />
        <action android:name="com.lulu.babytracker.OPEN_APP" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/lulu_widget_info" />
</receiver>
```

### Step 2: Handle Widget Actions in MainActivity

**Location:** `android/app/src/main/kotlin/com/lulu/babytracker/MainActivity.kt`

Update MainActivity to handle widget deep links:

```kotlin
package com.lulu.babytracker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lulu.babytracker/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWidgetAction" -> {
                        val action = intent?.getStringExtra("widget_action")
                        result.success(action)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        // Handle widget action
        val action = intent.getStringExtra("widget_action")
        if (action != null) {
            // Send action to Flutter via method channel
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onWidgetAction", action)
            }
        }
    }
}
```

### Step 3: Add Widget Preview Image

Create a placeholder preview image:

**Location:** `android/app/src/main/res/drawable/widget_preview.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <gradient
        android:angle="135"
        android:startColor="#F21A1F3A"
        android:endColor="#F22D3351"
        android:type="linear" />
    <corners android:radius="20dp" />
</shape>
```

### Step 4: Build and Test

```bash
# Clean build
flutter clean
flutter pub get

# Run on Android
flutter run -d android
```

**To test widgets:**
1. Long press on Android home screen
2. Tap **Widgets**
3. Find **Lulu** app
4. Drag widget to home screen

---

## 🔄 Data Flow

### Widget Update Process

```
Flutter App
    ↓ (saves data to HomeWidget)
SharedPreferences / AppGroup
    ↓ (reads data)
Native Widget
    ↓ (renders)
Home Screen
```

### Deep Link Flow

```
User taps widget button
    ↓
Native widget sends URI
    ↓
Flutter main.dart receives
    ↓
Navigator pushes screen
```

### Update Schedule

Widgets automatically update based on urgency:
- **5 minutes**: Action < 15 min away (critical)
- **10 minutes**: Action 15-30 min away (urgent)
- **15 minutes**: Action 30-60 min away (approaching)
- **30 minutes**: Default state

---

## 🎨 Widget Data Schema

### Shared Keys (iOS AppGroup / Android SharedPreferences)

```
widget_next_sweet_spot_time: String         // "14:30"
widget_minutes_until_sweet_spot: Int        // 52
widget_sweet_spot_progress: Double          // 0.65
widget_is_urgent: Boolean                   // false

widget_total_sleep_hours: Double            // 12.5
widget_total_feeding_count: Int             // 8
widget_total_diaper_count: Int              // 6

widget_next_action_type: String             // "sleep" | "feeding"
widget_next_action_time: String             // "14:30"
widget_next_action_minutes: Int             // 52

widget_next_feeding_time: String            // "15:45"
```

---

## 🌍 Internationalization

Widget strings are fully localized in English and Korean.

**Flutter Side:**
- Translations in `lib/core/localization/app_localizations.dart`
- Widgets use app's current locale

**iOS Side:**
- WidgetKit uses localized strings from Flutter
- Configure additional localizations in Xcode if needed

**Android Side:**
- Create `res/values-ko/strings.xml` for Korean
- Widget uses system locale automatically

---

## 🔧 Troubleshooting

### iOS Widgets Not Updating

1. **Verify App Group Configuration**
   ```swift
   // In LuluWidget.swift, check:
   let sharedDefaults = UserDefaults(suiteName: "group.com.lulu.babytracker")
   ```

2. **Check Widget Timeline**
   - Widgets may be throttled by iOS
   - Use `TimelineReloadPolicy.after(nextUpdate)` for manual control

3. **Debug with Console.app**
   ```bash
   # Open Console.app and filter for "LuluWidget"
   ```

### Android Widgets Not Appearing

1. **Verify AndroidManifest.xml**
   - Ensure `<receiver>` is properly declared
   - Check `android:exported="true"`

2. **Check Widget Info XML**
   ```bash
   # Verify the file exists
   android/app/src/main/res/xml/lulu_widget_info.xml
   ```

3. **ADB Logcat**
   ```bash
   adb logcat | grep LuluWidget
   ```

### Deep Links Not Working

1. **iOS URL Scheme**
   - Widgets use `lulu://` scheme
   - Verify scheme is registered in Info.plist

2. **Android Intent Filters**
   - Check intent-filter actions in AndroidManifest.xml
   - Ensure MainActivity handles widget actions

---

## 📊 Performance Optimization

### Battery Efficiency

**iOS:**
- WidgetKit automatically manages update frequency
- Smart refresh intervals (5-30 min) based on urgency
- Background refresh uses minimal resources

**Android:**
- `updatePeriodMillis` set to 15 minutes (900000ms)
- Manual updates triggered only when data changes
- No continuous background services

### Data Minimization

- Only essential data stored in shared preferences
- No heavy computations in widget code
- Calculations done in Flutter, widgets just render

---

## 🚀 Next Steps

After completing setup:

1. **Test All Widget Sizes**
   - Small (2×2)
   - Medium (4×2)
   - Lock Screen (iOS only)

2. **Verify Deep Links**
   - Tap sleep button → Log Sleep Screen
   - Tap feeding button → Log Feeding Screen
   - Tap diaper button → Log Diaper Screen

3. **Check Localization**
   - Switch app language to Korean
   - Verify widget updates with Korean text

4. **Monitor Updates**
   - Log activities and watch widgets update
   - Check update intervals are appropriate

5. **User Testing**
   - Test on various iOS/Android versions
   - Verify across different screen sizes

---

## 📝 Notes

- **App Group Name**: `group.com.lulu.babytracker` (must match exactly)
- **Widget Names**: `LuluSmallWidget`, `LuluMediumWidget`, `LuluLockScreenWidget`
- **Deep Link Scheme**: `lulu://`
- **Background Updates**: Managed by OS, not continuous

## 🎉 You're Done!

Your Lulu app now features beautiful, intelligent widgets that bring the core baby tracking experience to the home screen.

**Need help?** Check the troubleshooting section or review the native code files.
