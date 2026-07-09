import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_result.dart';
import 'wishlist_page.dart'; // Import MapMockPainter for visual placeholder fallback

/// LocationPickerPage provides the interactive map screen for locating places (Phase 6.1).
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
  String _resolvedAddress = '';
  bool _isLoading = false;
  final _geocoding = geo.Geocoding();

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLatLng = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _reverseGeocode(_selectedLatLng!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _useCurrentLocation();
      });
    }
  }

  void _animateTo(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(target));
  }

  /// Reverse geocodes the coordinates and formats them preferring landmark name over Plus Codes.
  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() {
      _isLoading = true;
      _resolvedAddress = 'Resolving address...';
    });
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.name;
        final street = place.street;
        final subLocality = place.subLocality;
        final locality = place.locality;
        final adminArea = place.administrativeArea;

        final isPlusCode = name != null && name.contains('+');

        final parts = <String>[];
        // Priority order: Landmark name -> Locality -> Street address
        if (name != null && name.isNotEmpty && !isPlusCode && name != street) {
          final isJustNumber = double.tryParse(name.replaceAll(RegExp(r'[^\d.]'), '')) != null;
          if (!isJustNumber) {
            parts.add(name);
          }
        }
        
        if (street != null && street.isNotEmpty) {
          parts.add(street);
        }
        if (subLocality != null && subLocality.isNotEmpty && subLocality != name) {
          parts.add(subLocality);
        }
        if (locality != null && locality.isNotEmpty) {
          parts.add(locality);
        }
        if (adminArea != null && adminArea.isNotEmpty) {
          parts.add(adminArea);
        }

        if (parts.isEmpty && name != null) {
          parts.add(name);
        }

        setState(() {
          _resolvedAddress = parts.join(', ');
        });
      } else {
        setState(() {
          _resolvedAddress = 'Coordinates: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (_) {
      setState(() {
        _resolvedAddress = 'Coordinates: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackbar('Location services are disabled.');
        _setFallbackCoordinates();
        return;
      }

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

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      
      setState(() {
        _selectedLatLng = target;
      });
      _animateTo(target);
      _reverseGeocode(target);
    } catch (e) {
      _showSnackbar('Failed to get GPS location.');
      _setFallbackCoordinates();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setFallbackCoordinates() {
    if (_selectedLatLng == null) {
      // Default neutral fallback if everything fails
      setState(() {
        _selectedLatLng = const LatLng(20.5937, 78.9629); // Center of India
      });
      _reverseGeocode(_selectedLatLng!);
    }
  }

  Future<void> _confirmLocation() async {
    final latLng = _selectedLatLng;
    if (latLng == null) return;

    if (_resolvedAddress.isEmpty || _resolvedAddress == 'Resolving address...') {
      await _reverseGeocode(latLng);
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      LocationResult(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        address: _resolvedAddress,
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
          : SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Live Map rendering OR visual placeholder
                  Positioned.fill(
                    bottom: 180, // Leave room for address bottom panel
                    child: hasKey
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                            onMapCreated: (controller) => _mapController = controller,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false, // Customized float button
                            zoomControlsEnabled: true,
                            compassEnabled: true,
                            onTap: (clickedLatLng) {
                              setState(() {
                                _selectedLatLng = clickedLatLng;
                              });
                              _reverseGeocode(clickedLatLng);
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('selected-loc'),
                                position: latLng,
                                draggable: true,
                                onDragEnd: (draggedLatLng) {
                                  setState(() {
                                    _selectedLatLng = draggedLatLng;
                                  });
                                  _reverseGeocode(draggedLatLng);
                                },
                              ),
                            },
                          )
                        : Stack(
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
                                        'Google Maps API Key has not been configured yet. You can still fetch GPS coordinates using your device GPS.',
                                        style: AppTypography.caption,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                  // Floating current GPS Button
                  Positioned(
                    bottom: 196,
                    right: AppSizes.p16,
                    child: FloatingActionButton(
                      onPressed: _useCurrentLocation,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),

                  // Address and Confirm Panel at the bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.p20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: AppSizes.shadowLevel3,
                        border: const Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Location',
                                style: AppTypography.overline.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _resolvedAddress.isEmpty ? 'Resolving location...' : _resolvedAddress,
                            style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSizes.gapH16,
                          Row(
                            children: [
                              Expanded(
                                child: GNButton(
                                  label: 'Cancel',
                                  variant: GNButtonVariant.secondary,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              AppSizes.gapW16,
                              Expanded(
                                child: GNButton(
                                  label: 'Confirm',
                                  variant: GNButtonVariant.primary,
                                  onPressed: _confirmLocation,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Loading HUD overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(color: AppColors.primary),
                    ),
                ],
              ),
            ),
    );
  }
}
