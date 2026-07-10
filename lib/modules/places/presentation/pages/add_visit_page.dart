import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';

/// AddVisitPage provides the premium sightseeing and nature/landmark travel spot form (Phase 5.3).
class AddVisitPage extends ConsumerStatefulWidget {
  final String? editPlaceId;

  const AddVisitPage({
    super.key,
    this.editPlaceId,
  });

  @override
  ConsumerState<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends ConsumerState<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _feeController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String _selectedCategory = 'Nature / Park';
  String _selectedSeason = 'Winter';
  double _rating = 4.0;
  bool _isVisited = false;
  bool _isWishlist = true;

  double? _lat;
  double? _lng;
  bool _isGeocoding = false;
  geo.Geocoding get _geocoding => geo.Geocoding();

  String? _imagePath = 'assets/images/visits/default_1.png';
  String _imageType = 'asset'; // 'asset' or 'file'

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

    if (widget.editPlaceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFields();
      });
    }
  }

  void _populateFields() {
    final places = ref.read(placesListProvider).value ?? [];
    final editPlace = places.firstWhere((p) => p.id == widget.editPlaceId);
    setState(() {
      _nameController.text = editPlace.name;
      _descController.text = editPlace.description;
      _locController.text = editPlace.location;
      _selectedCategory = editPlace.category;
      _selectedSeason = editPlace.bestTime ?? 'Winter';
      _feeController.text = editPlace.entryFee ?? '';
      _rating = editPlace.rating;
      _isVisited = editPlace.isVisited;
      _isWishlist = editPlace.isWishlist;
      _lat = editPlace.latitude;
      _lng = editPlace.longitude;
      _imagePath = editPlace.imageUrl;
      _imageType = editPlace.imageType;
      if (_lat != null) _latController.text = _lat.toString();
      if (_lng != null) _lngController.text = _lng.toString();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _imageType = 'file';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSizes.gapH24,
                Text(
                  'Choose Image',
                  style: AppTypography.title.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select how you would like to add an image.',
                  style: AppTypography.caption,
                ),
                AppSizes.gapH24,
                _buildPickerOptionTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  subtitle: 'Take a new picture',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                AppSizes.gapH12,
                _buildPickerOptionTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Gallery',
                  subtitle: 'Choose from your gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                AppSizes.gapH12,
                _buildPickerOptionTile(
                  icon: Icons.image_outlined,
                  title: 'Default Image',
                  subtitle: 'Use bundled category image',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagePath = 'assets/images/visits/default_1.png';
                      _imageType = 'asset';
                    });
                  },
                ),
                AppSizes.gapH24,
                SizedBox(
                  width: double.infinity,
                  child: GNButton(
                    label: 'Cancel',
                    variant: GNButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFaint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.caption),
                    ],
                  ),
                ),
                 Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String type, String? path) {
    if (path == null || path.isEmpty) {
      return Container(color: AppColors.surfaceFaint);
    }
    if (type == 'file') {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else {
        return Container(
          color: AppColors.surfaceFaint,
          child: Center(
            child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 48),
          ),
        );
      }
    } else if (type == 'asset') {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
        return Container(color: AppColors.surfaceFaint);
      });
    } else {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
        return Container(color: AppColors.surfaceFaint);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locController.dispose();
    _feeController.dispose();
    _latController.dispose();
    _lngController.dispose();
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
        _latController.text = _lat.toString();
        _lngController.text = _lng.toString();
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
        final name = place.name;
        final street = place.street;
        final subLocality = place.subLocality;
        final locality = place.locality;
        final adminArea = place.administrativeArea;

        final isPlusCode = name != null && name.contains('+');

        final parts = <String>[];
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

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final loc = _locController.text.trim();
      final fee = _feeController.text.trim();

      if (loc.isEmpty) {
        _showSnackbar('Location/Address is required.');
        return;
      }

      final places = ref.read(placesListProvider).value ?? [];
      final isDuplicate = places.any((p) =>
          p.name.toLowerCase() == name.toLowerCase() &&
          p.id != widget.editPlaceId &&
          p.type == 'visit');

      if (isDuplicate) {
        _showSnackbar('A place with this name already exists.');
        return;
      }

      final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      if (widget.editPlaceId != null) {
        final existing = places.firstWhere((p) => p.id == widget.editPlaceId);
        final updated = PlaceModel(
          id: existing.id,
          name: name,
          description: desc,
          category: _selectedCategory,
          budget: fee.isEmpty ? 'Free' : 'Paid',
          location: loc,
          rating: _rating,
          isVisited: _isVisited,
          isWishlist: _isWishlist,
          imageUrl: _imagePath ?? 'assets/images/visits/default_1.png',
          type: 'visit',
          entryFee: fee.isEmpty ? 'Free' : fee,
          bestTime: _selectedSeason,
          latitude: _lat,
          longitude: _lng,
          dateAdded: existing.dateAdded,
          lastUpdated: nowStr,
          imageType: _imageType,
        );
        await ref.read(placesListProvider.notifier).updatePlace(updated);
        _showSnackbar('Place details updated successfully.');
      } else {
        final newPlace = PlaceModel(
          id: const Uuid().v4(),
          name: name,
          description: desc,
          category: _selectedCategory,
          budget: fee.isEmpty ? 'Free' : 'Paid',
          location: loc,
          rating: _rating,
          isVisited: _isVisited,
          isWishlist: _isWishlist,
          imageUrl: _imagePath ?? 'assets/images/visits/default_1.png',
          type: 'visit',
          entryFee: fee.isEmpty ? 'Free' : fee,
          bestTime: _selectedSeason,
          latitude: _lat,
          longitude: _lng,
          dateAdded: nowStr.split(' ').first,
          lastUpdated: nowStr,
          imageType: _imageType,
        );
        await ref.read(placesListProvider.notifier).addPlace(newPlace);
        _showSnackbar('Place saved successfully.');
      }

      if (mounted) {
        context.pop();
      }
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
        title: Text(widget.editPlaceId != null ? 'Edit Place' : 'New Place', style: AppTypography.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
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
                    InkWell(
                      onTap: _showImagePickerOptions,
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.r24),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFaint,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImageWidget(_imageType, _imagePath),
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
                              decoration: InputDecoration(
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
                          decoration: InputDecoration(
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
                              decoration: InputDecoration(
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
                              decoration: InputDecoration(
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
                        if (_locController.text.isNotEmpty) ...[
                          AppSizes.gapH8,
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _locController.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Address copied to clipboard'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                                label: Text(
                                  'Copy Address',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              if (_lat != null && _lng != null) ...[
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: '$_lat,$_lng'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Coordinates copied to clipboard'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.primary),
                                  label: Text(
                                    'Copy Coordinates',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ],
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
                                          Icon(Icons.map_rounded, color: AppColors.primary, size: 32),
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
                                    child: CircularProgressIndicator(color: AppColors.primary),
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
                                      controller: _latController,
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
                                      controller: _lngController,
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
                          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
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
                                     Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text('Date Added: $_dateAdded', style: AppTypography.caption),
                                  ],
                                ),
                                AppSizes.gapH2,
                                Row(
                                  children: [
                                     Icon(Icons.update_rounded, size: 14, color: AppColors.textSecondary),
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
            decoration: BoxDecoration(
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
