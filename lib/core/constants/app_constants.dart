/// AppConstants contains non-UI global constants for the GoNext application.
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'GoNext';

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animDefault = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Hive Box Names Placeholder
  static const String placesBox = 'places_box';
  static const String settingsBox = 'settings_box';

  /// Google Maps API Key.
  /// 
  /// How to configure:
  /// 
  /// 1. Android Configuration:
  ///    - Open `android/app/src/main/AndroidManifest.xml`.
  ///    - Under the `<application>` tag, configure the geo API_KEY metadata:
  ///      `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>`
  /// 
  /// 2. iOS Configuration:
  ///    - Open `ios/Runner/AppDelegate.swift`.
  ///    - Import GoogleMaps: `import GoogleMaps`
  ///    - Inside `application(_:didFinishLaunchingWithOptions:)`, add:
  ///      `GMSServices.provideAPIKey("YOUR_KEY")`
  /// 
  /// If set to 'YOUR_API_KEY' or left empty, the application will gracefully fall back
  /// to displaying a premium placeholder explaining that a Maps API key is required.
  static const String googleMapsApiKey = 'AIzaSyBbGLhGj04oNNKQBzZ6WUIcY9TEp0H5cfU';

  /// Returns true if the Google Maps API Key has been configured with a valid non-placeholder value.
  static bool get isMapsApiKeyValid {
    return googleMapsApiKey.isNotEmpty &&
        googleMapsApiKey != 'YOUR_API_KEY' &&
        !googleMapsApiKey.startsWith('PLACEHOLDER');
  }
}
