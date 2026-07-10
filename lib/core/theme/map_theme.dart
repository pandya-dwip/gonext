import 'package:google_maps_flutter/google_maps_flutter.dart';

/// MapTheme contains helper utilities and JSON style declarations for Google Maps.
class MapTheme {
  MapTheme._();

  /// Updates map controller styling based on the active dark mode state
  static Future<void> applyMapStyle(GoogleMapController controller, bool isDark) async {
    if (isDark) {
      await controller.setMapStyle(_darkMapStyle);
    } else {
      await controller.setMapStyle(null);
    }
  }

  // Sleek M3-inspired dark map style
  static const String _darkMapStyle = r'''
[
  {
    "elementType": "geometry",
    "stylers": [
      {"color": "#1e1e1e"}
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#1e1e1e"}
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#747474"}
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {"visibility": "off"}
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#dfdfdf"}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#dfdfdf"}
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {"color": "#181d1a"}
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#617f6b"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"color": "#2c2c2c"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#212121"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#8a8a8a"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {"color": "#3c3c3c"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#2f2f2f"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#c4c4c4"}
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {"color": "#2f2f2f"}
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#dfdfdf"}
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {"color": "#0e161a"}
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#3d5661"}
    ]
  }
]
''';
}
