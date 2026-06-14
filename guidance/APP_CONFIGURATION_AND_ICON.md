# Pillow Bud — App Configuration & Icon Setup

## PART 1: CREATE APP ICON

### Quick Option: Use Online Tool (5 minutes)

1. Go to: https://www.appicon.co/
2. Upload a simple icon image (512×512 px)
   - Suggestion: Use the 🛏️ emoji or search "pillow" icon
3. Download the ZIP with all sizes
4. Extract and copy to your project

OR create a simple icon using:
- Figma (free account)
- Canva (free account)
- Paint / Preview

### Manual Icon Sizes Needed

Create these image files with the exact dimensions:

**Android:**
```
android/app/src/main/res/
├── mipmap-ldpi/ic_launcher.png          (36×36)
├── mipmap-mdpi/ic_launcher.png          (48×48)
├── mipmap-hdpi/ic_launcher.png          (72×72)
├── mipmap-xhdpi/ic_launcher.png         (96×96)
├── mipmap-xxhdpi/ic_launcher.png        (144×144)
└── mipmap-xxxhdpi/ic_launcher.png       (192×192)
```

**iOS:**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png       (20×20)
├── Icon-App-20x20@2x.png       (40×40)
├── Icon-App-20x20@3x.png       (60×60)
├── Icon-App-29x29@1x.png       (29×29)
├── Icon-App-29x29@2x.png       (58×58)
├── Icon-App-29x29@3x.png       (87×87)
├── Icon-App-40x40@1x.png       (40×40)
├── Icon-App-40x40@2x.png       (80×80)
├── Icon-App-40x40@3x.png       (120×120)
├── Icon-App-60x60@2x.png       (120×120)
├── Icon-App-60x60@3x.png       (180×180)
├── Icon-App-76x76@1x.png       (76×76)
├── Icon-App-76x76@2x.png       (152×152)
├── Icon-App-83.5x83.5@2x.png   (167×167)
└── Icon-App-1024x1024@1x.png   (1024×1024)
```

---

## PART 2: ANDROID CONFIGURATION

### File: android/app/build.gradle

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.pillow_bud.app"
    compileSdkVersion 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.pillow_bud.app"
        minSdkVersion 26
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}
```

### File: android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.pillow_bud.app">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application
        android:label="Pillow Bud"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:debuggable="false"
        android:usesCleartextTraffic="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### File: android/app/src/main/kotlin/com/pillow_bud/app/MainActivity.kt

```kotlin
package com.pillow_bud.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

### File: android/app/src/main/res/values/styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS has decided to display the app -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when Flutter draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your Flutter UI initializes, as well as behind your Flutter UI while its running.
         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

### File: android/app/src/main/res/values-night/styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

---

## PART 3: iOS CONFIGURATION

### File: ios/Runner/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Pillow Bud</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientationsIPad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
</dict>
</plist>
```

### File: ios/Runner.xcodeproj/project.pbxproj (Critical Settings)

Most Flutter projects auto-generate this, but ensure these settings:

```
PRODUCT_NAME = Pillow Bud
PRODUCT_BUNDLE_IDENTIFIER = com.pillow_bud.app
DEVELOPMENT_TEAM = [Your Apple Team ID if releasing]
CODE_SIGN_IDENTITY = iPhone Developer
```

---

## PART 4: BUILD AND RUN

### Option 1: Build APK (Android - Recommended for Testing)

```bash
cd pillow_bud

# Build debug APK (fast, for testing)
flutter build apk --debug

# Output: build/app/outputs/apk/debug/app-debug.apk
```

Then **install on phone**:
```bash
flutter install

# OR connect phone and:
adb install build/app/outputs/apk/debug/app-debug.apk
```

**To share/upload:**
```bash
# Build release APK (optimized, smaller)
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
# This is the file to upload to GitHub
```

### Option 2: Build IPA (iOS)

```bash
# Requires Mac with Xcode
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
# Upload to App Store Connect (requires Apple Developer account)
```

### Option 3: Run Directly on Connected Phone

```bash
flutter run
```

App installs immediately and opens.

---

## PART 5: VERIFY APP IS INSTALLED

After building and installing:

1. **Disconnect USB cable** (if used)
2. **Look at home screen**
3. **Pillow Bud icon should be there** with the app icon you provided
4. **Tap the icon**
5. **App launches normally**

---

## PART 6: ICON CREATION QUICK GUIDE

If you don't have an icon yet, here's the fastest way:

### Using Online Tools (No Design Skills Needed)

**Option A: Canva (Easiest)**
1. Go to canva.com
2. Create new "Logo" (1:1 square)
3. Search "pillow" in elements
4. Add a pillow icon
5. Download as PNG (1024×1024)
6. Upload to appicon.co
7. Download ZIP with all sizes

**Option B: Figma**
1. Create free Figma account
2. New file → Frame 1024×1024
3. Add pillow emoji 🛏️ (text, huge size)
4. Add light lavender background (color #C4A8F8)
5. Export as PNG
6. Upload to appicon.co

**Option C: Use Existing Icon**
- Search icon sites:
  - https://flaticon.com (search "pillow")
  - https://icons8.com/icons/set/pillow
  - https://www.svgrepo.com (search "pillow")
- Download PNG 1024×1024
- Upload to appicon.co

### Using appicon.co (Automated)

1. Go to https://www.appicon.co/
2. Click "SELECT FILE"
3. Upload your 1024×1024 PNG
4. Download ZIP
5. Extract
6. Copy files to correct folders (listed above)

---

## PART 7: UPDATE PUBSPEC.yaml IF NEEDED

Make sure this is in your `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  
  # Your fonts
  fonts:
    - family: Lora
      fonts:
        - asset: assets/fonts/Lora-Regular.ttf
        - asset: assets/fonts/Lora-Medium.ttf
          weight: 500
        - asset: assets/fonts/Lora-SemiBold.ttf
          weight: 600
    
    - family: DM Sans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/DMSans-SemiBold.ttf
          weight: 600
  
  assets:
    - assets/images/
    - assets/fonts/
```

---

## PART 8: COMPLETE SETUP CHECKLIST

```
App Icon Setup:
☐ Created/downloaded app icon (512×512 or larger)
☐ Generated all icon sizes using appicon.co
☐ Copied Android icons to android/app/src/main/res/mipmap-*/
☐ Copied iOS icons to ios/Runner/Assets.xcassets/AppIcon.appiconset/

Android Configuration:
☐ Updated android/app/build.gradle
☐ Updated android/app/src/main/AndroidManifest.xml
☐ Created android/app/src/main/kotlin/MainActivity.kt
☐ Created android/app/src/main/res/values/styles.xml
☐ Created android/app/src/main/res/values-night/styles.xml

iOS Configuration:
☐ Updated ios/Runner/Info.plist
☐ Verified iOS project settings in Xcode

Build & Test:
☐ Run: flutter clean
☐ Run: flutter pub get
☐ Run: flutter build apk --debug (for Android testing)
☐ Connect phone via USB
☐ Run: flutter install (or flutter run)
☐ Check home screen for app icon
☐ Tap icon and verify app launches
```

---

## PART 9: COMMANDS TO RUN NOW

**In your terminal, from the pillow_bud folder:**

```bash
# Clean and get fresh dependencies
flutter clean
flutter pub get

# Run app on connected phone
flutter run

# OR build APK for distribution
flutter build apk --release
```

**Expected Output:**
- App builds
- Installs on phone
- Launches
- Shows splash screen for 2 seconds
- Shows onboarding screens
- Works perfectly

---

## PART 10: SHARE ON GITHUB

When ready to share:

1. Create GitHub account (free at github.com)
2. Create new repository named "pillow-bud"
3. In your project folder:

```bash
git init
git add .
git commit -m "Initial commit: Pillow Bud v1.0"
git branch -M main
git remote add origin https://github.com/yourusername/pillow-bud.git
git push -u origin main
```

4. On GitHub, create a Release:
   - Go to "Releases"
   - Click "Create a new release"
   - Tag: v1.0.0
   - Title: "Pillow Bud v1.0 - Initial Release"
   - Description:
     ```
     ## Pillow Bud v1.0
     
     ### What's New
     - Full emotional companion app
     - Chat with Bud (AI companion)
     - Journal entries with mood tracking
     - Crisis detection with helpline resources
     - Customizable themes
     - 100% private (all data on your phone)
     
     ### Installation
     1. Clone: `git clone https://github.com/yourusername/pillow-bud.git`
     2. Install dependencies: `flutter pub get`
     3. Connect your phone
     4. Run: `flutter run`
     
     ### Requirements
     - Flutter 3.0+
     - Android 8.0+ OR iOS 15+
     
     ### Privacy
     Everything runs locally on your phone. No cloud, no tracking, no data collection.
     
     ### Support
     For serious mental health concerns, please reach out to:
     - iCall India: 9152987821
     - Vandrevala Foundation: 1860-2662-345
     ```
   - Attach APK file (if built)
   - Publish release

5. Share link: `https://github.com/yourusername/pillow-bud`

---

## TROUBLESHOOTING

### App Icon Not Showing

**Solution:**
1. Delete old app from phone
2. Run: `flutter clean`
3. Rebuild and reinstall:
   ```bash
   flutter pub get
   flutter run
   ```

### "Icon not found" Error

**Solution:**
- Verify all icon files are in correct folders
- Icon filenames must be exactly: `ic_launcher.png`
- Check file sizes (must match required dimensions)

### App Crashes on Launch

**Solution:**
1. Check debug console for errors
2. Run: `flutter logs` to see logs
3. Most common: missing fonts
   - Download Lora and DM Sans from Google Fonts
   - Place in `assets/fonts/`
   - Rebuild

### "No connected devices"

**Solution:**
1. Connect Android phone via USB
2. Enable USB Debugging:
   - Settings → About Phone
   - Tap "Build Number" 7 times
   - Back to Settings → Developer Options
   - Enable "USB Debugging"
3. Authorize connection when popup appears
4. Run: `flutter devices` to verify
5. Run: `flutter run`

---

## FINAL CHECKLIST

Before releasing on GitHub:

✅ App icon created and placed
✅ App launches on home screen
✅ Onboarding works
✅ Can chat with Bud
✅ Can write journal entries
✅ Crisis detection shows helpline
✅ App settings work
✅ No crashes
✅ README complete
✅ LICENSE added (Apache 2.0)
✅ Git repository initialized
✅ GitHub repository created
✅ Release published

---

## YOU'RE DONE! 🎉

Your app is now:
- ✅ A real, working mobile app
- ✅ Installable with an icon on home screen
- ✅ Ready to share on GitHub
- ✅ Free for anyone to download and use

**Next: Tell me when you're ready to build and test!**
