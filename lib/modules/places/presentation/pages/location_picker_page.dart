import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_button.dart';
import '../../domain/entities/location_result.dart';
import 'wishlist_page.dart'; // Import MapMockPainter for visual placeholder fallback

/// LocationPickerPage provides a full-screen live Google Maps interface
/// to select location coordinates. It relies on GPS locator inputs (Phase 5.3).
class LocationPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;
  bool _isLoading = false;
  geo.Geocoding get _geocoding => geo.Geocoding();
  String _resolvedAddress = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLatLng = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      // Automatically request location and fetch user's current GPS location on empty load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _useCurrentLocation();
      });
    }
  }

  /// Animates the map camera to a coordinate
  void _animateTo(LatLng latLng) {
    if (!AppConstants.isMapsApiKeyValid) return;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  /// Fetches current location using Geolocator GPS
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar('Location permission denied.');
          _setFallbackCoordinates();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar('Location permissions are permanently denied.');
        _setFallbackCoordinates();
        return;
      }

      // Fetch fresh coordinate pair directly
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      
      // Reverse geocode right away
      String addressResult = 'Unknown Address';
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            if (place.street != null && place.street!.isNotEmpty) place.street,
            if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
            if (place.locality != null && place.locality!.isNotEmpty) place.locality,
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
          ];
          addressResult = parts.join(', ');
        }
      } catch (_) {
        addressResult = 'Coordinates: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      }

      setState(() {
        _selectedLatLng = target;
        _resolvedAddress = addressResult;
      });
      _animateTo(target);
      _showSnackbar('Located: $addressResult');
    } catch (e) {
      _showSnackbar('Failed to get GPS location.');
      _setFallbackCoordinates();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setFallbackCoordinates() {
    if (_selectedLatLng == null) {
      setState(() {
        _selectedLatLng = const LatLng(20.5937, 78.9629); // Center of India (neutral fallback if GPS fails)
      });
    }
  }

  /// Resolves the human-readable address description and pops back
  Future<void> _confirmLocation() async {
    final latLng = _selectedLatLng;
    if (latLng == null) return;
    setState(() => _isLoading = true);
    String resolved = _resolvedAddress;
    
    // Resolve address if not already reverse-geocoded
    if (resolved.isEmpty) {
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            if (place.street != null && place.street!.isNotEmpty) place.street,
            if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
            if (place.locality != null && place.locality!.isNotEmpty) place.locality,
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
          ];
          resolved = parts.join(', ');
        }
      } catch (_) {
        resolved = 'Coordinates: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
      }
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(
      context,
      LocationResult(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        address: resolved,
      ),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasKey = AppConstants.isMapsApiKeyValid;
    final latLng = _selectedLatLng;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Location', style: AppTypography.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: latLng == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  AppSizes.gapH16,
                  Text('Fetching current GPS location...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                // Live Map rendering OR graceful visual placeholder
                if (hasKey)
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                    onMapCreated: (controller) => _mapController = controller,
                    onTap: (clickedLatLng) {
                      setState(() {
                        _selectedLatLng = clickedLatLng;
                        _resolvedAddress = ''; // Reset to force geocode on confirm
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected-loc'),
                        position: latLng,
                        draggable: true,
                        onDragEnd: (draggedLatLng) {
                          setState(() {
                            _selectedLatLng = draggedLatLng;
                            _resolvedAddress = '';
                          });
                        },
                      ),
                    },
                  )
                else
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: MapMockPainter(),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                          padding: const EdgeInsets.all(AppSizes.p24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.r24),
                            boxShadow: AppSizes.shadowLevel2,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_outlined, color: AppColors.primary, size: 48),
                              AppSizes.gapH16,
                              Text(
                                'Interactive Map Disabled',
                                style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              AppSizes.gapH8,
                              Text(
                                'Google Maps API Key has not been configured yet. You can still tap the location button below to fetch GPS coordinates, or enter them in the Advanced Coordinates form.',
                                style: AppTypography.caption,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                // Loading HUD overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: AppColors.primary),
                  ),

                // Floating current GPS Button - always visible!
                Positioned(
                  bottom: 100,
                  right: AppSizes.p16,
                  child: FloatingActionButton(
                    onPressed: _useCurrentLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),

                // Confirm button anchored at bottom-center
                Positioned(
                  bottom: AppSizes.p24,
                  left: AppSizes.p24,
                  right: AppSizes.p24,
                  child: GNButton(
                    label: 'Confirm Location',
                    variant: GNButtonVariant.primary,
                    fullWidth: true,
                    onPressed: _confirmLocation,
                  ),
                ),
              ],
            ),
    );
  }
}
