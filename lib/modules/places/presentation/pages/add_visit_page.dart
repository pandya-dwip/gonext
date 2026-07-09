import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_button.dart';
import '../../../../shared/components/gn_searchable_selector.dart';
import '../../domain/entities/location_result.dart';
import 'wishlist_page.dart'; // import MapMockPainter for maps preview

/// AddVisitPage provides the premium sightseeing and nature/landmark travel spot form (Phase 5.3).
class AddVisitPage extends StatefulWidget {
  const AddVisitPage({super.key});

  @override
  State<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _feeController = TextEditingController();

  String _selectedCategory = 'Nature / Park';
  String _selectedSeason = 'Winter';
  double _rating = 4.0;
  bool _isVisited = false;
  bool _isWishlist = true;

  double? _lat;
  double? _lng;
  bool _isGeocoding = false;
  geo.Geocoding get _geocoding => geo.Geocoding();

  // Read-only Dates
  late final String _dateAdded;
  late final String _lastUpdated;

  static const List<String> _categories = [
    'Nature / Park', 'Heritage / History', 'Nature / Walk', 'Festival / Nightlife',
    'Museum / Art', 'Beach / Coastal', 'Adventure / Trek', 'Amusement Park',
    'Religious Place', 'Shopping Street', 'Scenic Viewpoint', 'Other'
  ];

  static const List<String> _seasons = [
    'Spring', 'Summer', 'Autumn', 'Winter', 'Monsoon', 'All Season'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    _dateAdded = fmt.format(now);
    _lastUpdated = fmt.format(now);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  /// Launch full screen map picker and capture coordinate result
  Future<void> _pickLocation() async {
    final latParam = _lat != null ? 'lat=$_lat' : '';
    final lngParam = _lng != null ? 'lng=$_lng' : '';
    final query = [if (latParam.isNotEmpty) latParam, if (lngParam.isNotEmpty) lngParam].join('&');
    final path = '/location-picker${query.isNotEmpty ? '?$query' : ''}';
    final result = await context.push<LocationResult>(path);
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _locController.text = result.address;
      });
    }
  }

  /// Reverse geocode manually entered coordinates
  Future<void> _reverseGeocodeCoords() async {
    final lat = _lat;
    final lng = _lng;
    if (lat == null || lng == null) return;
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) return;

    setState(() => _isGeocoding = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
        ];
        setState(() {
          _locController.text = parts.join(', ');
        });
      }
    } catch (_) {
      setState(() {
        _locController.text = 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      });
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  /// Tap map preview handler: open picker OR external Google Maps app
  Future<void> _handleMapPreviewTap() async {
    final bool hasMapKey = AppConstants.isMapsApiKeyValid;
    if (hasMapKey) {
      await _pickLocation();
    } else {
      if (_lat != null && _lng != null) {
        final urlString = 'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng';
        try {
          if (await canLaunchUrlString(urlString)) {
            await launchUrlString(urlString, mode: LaunchMode.externalApplication);
          } else {
            _showSnackbar('Could not open external Google Maps.');
          }
        } catch (_) {
          _showSnackbar('Could not open external Google Maps.');
        }
      } else {
        await _pickLocation();
      }
    }
  }

  /// Show the searchable category selector sheet
  Future<void> _showCategorySelector() async {
    final result = await GNSearchableSelector.show(
      context,
      title: 'Select Category',
      options: _categories,
      initialValue: _selectedCategory,
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  /// Show the searchable season selector sheet
  Future<void> _showSeasonSelector() async {
    final result = await GNSearchableSelector.show(
      context,
      title: 'Select Best Season',
      options: _seasons,
      initialValue: _selectedSeason,
    );
    if (result != null) {
      setState(() {
        _selectedSeason = result;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${_nameController.text} to Visits!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMapKey = AppConstants.isMapsApiKeyValid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New Place', style: AppTypography.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSizes.p16,
                right: AppSizes.p16,
                top: AppSizes.p16,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Image Hero Header Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceFaint,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&auto=format&fit=crop&q=60',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.blue.shade50,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: AppSizes.p16,
                              left: AppSizes.p16,
                              right: AppSizes.p16,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blue,
                                    child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 24),
                                  ),
                                  AppSizes.gapW16,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Travel Inspired',
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.blue.shade300,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'New Landmark',
                                          style: AppTypography.titleLarge.copyWith(
                                            color: Colors.white,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          'Save heritage spots, state parks, and museums.',
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSizes.gapH24,

                    // Card 1: Place details
                    _buildSectionCard(
                      title: 'Place Details',
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: AppTypography.bodyEmphasis,
                          decoration: const InputDecoration(
                            labelText: 'Place Name *',
                            hintText: 'e.g. Grand Canyon',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a place name';
                            }
                            return null;
                          },
                        ),
                        AppSizes.gapH16,
                        TextFormField(
                          controller: _descController,
                          style: AppTypography.body,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Describe scenery, trail steps, or hours...',
                          ),
                        ),
                        AppSizes.gapH16,

                        // Searchable Category Input
                        InkWell(
                          onTap: _showCategorySelector,
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: TextEditingController(text: _selectedCategory),
                              style: AppTypography.bodyEmphasis,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.gapH16,

                    // Card 2: Costs & Season
                    _buildSectionCard(
                      title: 'Entry Fees & Season',
                      children: [
                        TextFormField(
                          controller: _feeController,
                          style: AppTypography.body,
                          decoration: const InputDecoration(
                            labelText: 'Entry Fee / Ticket Cost',
                            hintText: 'e.g. Free or ₹250 per head',
                            prefixIcon: Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                          ),
                        ),
                        AppSizes.gapH16,

                        // Searchable Season Input
                        InkWell(
                          onTap: _showSeasonSelector,
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: TextEditingController(text: _selectedSeason),
                              style: AppTypography.bodyEmphasis,
                              decoration: const InputDecoration(
                                labelText: 'Best Time to Visit *',
                                suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.gapH16,

                    // Card 3: Visited & Rating details
                    _buildSectionCard(
                      title: 'Visits & Ratings',
                      children: [
                        SwitchListTile(
                          title: Text('Wishlist', style: AppTypography.bodyEmphasis),
                          subtitle: Text('Save as a place you want to travel to.', style: AppTypography.caption),
                          value: _isWishlist,
                          onChanged: (val) => setState(() => _isWishlist = val),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: Text('Visited', style: AppTypography.bodyEmphasis),
                          subtitle: Text('Mark if you have already visited here.', style: AppTypography.caption),
                          value: _isVisited,
                          onChanged: (val) => setState(() => _isVisited = val),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_isVisited) ...[
                          AppSizes.gapH16,
                          Text('RATING', style: AppTypography.overline),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _rating,
                                  min: 1.0,
                                  max: 5.0,
                                  divisions: 40,
                                  label: _rating.toStringAsFixed(1),
                                  activeColor: AppColors.primary,
                                  inactiveColor: AppColors.surfaceFaint,
                                  onChanged: (val) => setState(() => _rating = val),
                                ),
                              ),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    AppSizes.gapH16,

                    // Card 4: Location details
                    _buildSectionCard(
                      title: 'Location / Address',
                      children: [
                        InkWell(
                          onTap: _pickLocation,
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _locController,
                              style: AppTypography.body,
                              decoration: const InputDecoration(
                                labelText: 'Select Location *',
                                hintText: 'Tap to open location picker...',
                                prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please select a location';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        if (_lat != null && _lng != null) ...[
                          AppSizes.gapH8,
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'Coordinates: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                        AppSizes.gapH12,

                        // Location Preview Box (Clickable maps fallback launcher)
                        InkWell(
                          onTap: _handleMapPreviewTap,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceFaint,
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (hasMapKey) ...[
                                  if (_lat != null && _lng != null)
                                    AbsorbPointer(
                                      child: GoogleMap(
                                        key: ValueKey('map-$_lat-$_lng'),
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(_lat!, _lng!),
                                          zoom: 14,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: const MarkerId('preview-loc'),
                                            position: LatLng(_lat!, _lng!),
                                          ),
                                        },
                                        zoomControlsEnabled: false,
                                        myLocationButtonEnabled: false,
                                        liteModeEnabled: true,
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.map_rounded, color: AppColors.primary, size: 32),
                                          AppSizes.gapH8,
                                          Text(
                                            'No location selected yet',
                                            style: AppTypography.bodyEmphasis.copyWith(color: AppColors.textSecondary),
                                          ),
                                          Text(
                                            'Tap to select a location on map',
                                            style: AppTypography.caption.copyWith(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                ] else ...[
                                  CustomPaint(painter: MapMockPainter()),
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    padding: const EdgeInsets.all(AppSizes.p16),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.map_rounded, color: Colors.white, size: 24),
                                        AppSizes.gapH4,
                                        Text(
                                          _lat != null && _lng != null
                                              ? 'Tap to open in Google Maps application.'
                                              : 'Tap to pick/enter coordinates manually.',
                                          style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (_isGeocoding)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(color: AppColors.primary),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        AppSizes.gapH12,

                        // Advanced Location Coordinate entry
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              'Advanced Location Options',
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            tilePadding: EdgeInsets.zero,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Latitude',
                                        hintText: 'e.g. 19.0760',
                                      ),
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          final d = double.tryParse(val);
                                          if (d == null || d < -90.0 || d > 90.0) {
                                            return 'Lat must be -90 to 90';
                                          }
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        final d = double.tryParse(val);
                                        if (d != null && d >= -90.0 && d <= 90.0) {
                                          _lat = d;
                                          if (_lng != null) _reverseGeocodeCoords();
                                        }
                                      },
                                    ),
                                  ),
                                  AppSizes.gapW16,
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Longitude',
                                        hintText: 'e.g. 72.8777',
                                      ),
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          final d = double.tryParse(val);
                                          if (d == null || d < -180.0 || d > 180.0) {
                                            return 'Lng must be -180 to 180';
                                          }
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        final d = double.tryParse(val);
                                        if (d != null && d >= -180.0 && d <= 180.0) {
                                          _lng = d;
                                          if (_lat != null) _reverseGeocodeCoords();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSizes.gapH24,

                    // Upgraded visual Audit Metadata Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.p16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFaint,
                        borderRadius: BorderRadius.circular(AppSizes.r24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
                          AppSizes.gapW16,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AUDIT METADATA',
                                  style: AppTypography.overline.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text('Date Added: $_dateAdded', style: AppTypography.caption),
                                  ],
                                ),
                                AppSizes.gapH2,
                                Row(
                                  children: [
                                    const Icon(Icons.update_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text('Last Updated: $_lastUpdated', style: AppTypography.caption),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.gapH32,
                  ],
                ),
              ),
            ),
          ),

          // Sticky Button Bar at bottom
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              boxShadow: AppSizes.shadowLevel1,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GNButton(
                    label: 'Cancel',
                    variant: GNButtonVariant.secondary,
                    onPressed: () => context.pop(),
                  ),
                ),
                AppSizes.gapW16,
                Expanded(
                  child: GNButton(
                    label: 'Save',
                    variant: GNButtonVariant.primary,
                    onPressed: _saveForm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTypography.overline.copyWith(color: AppColors.primary)),
          AppSizes.gapH12,
          ...children,
        ],
      ),
    );
  }
}
