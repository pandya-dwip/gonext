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
}
