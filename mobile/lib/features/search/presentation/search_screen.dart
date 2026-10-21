import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class SearchParkingSpot {
  final String id;
  final String name;
  final String area;
  final double distanceKm;
  final double ratePerHour;
  final bool isCovered;
  final bool hasCctv;
  final bool isVerified;
  final LatLng position;
  final int availableBays;

  SearchParkingSpot({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    required this.ratePerHour,
    required this.isCovered,
    required this.hasCctv,
    required this.isVerified,
    required this.position,
    required this.availableBays,
  });
}

class SearchScreen extends StatefulWidget {
  final String destination;
  const SearchScreen({super.key, required this.destination});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Default to Pune / Central coordinates as initial anchor
  LatLng _mapCenter = const LatLng(18.5204, 73.8567);
  LatLng? _userDeviceLocation;
  String? _searchedDestinationTitle;
  LatLng? _searchedDestinationLatLng;
  String? _selectedSpotId;

  final MapController _mapController = MapController();
  late TextEditingController _searchCtrl;
  bool _isSearchingLocation = false;
  bool _isDetectingGps = false;
  List<Map<String, dynamic>> _osmSearchResults = [];

  // Filter switches
  bool _filterCompatible = true;
  bool _filterCovered = false;
  bool _filterCctv = false;

  List<SearchParkingSpot> _nearbySpots = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.destination);

    // Initial spots generation around initial center
    _nearbySpots = _generateSpotsAround(_mapCenter, widget.destination.isNotEmpty ? widget.destination : 'Central');

    // Run initial search or location resolution
    if (widget.destination.isNotEmpty) {
      _searchOpenStreetMap(widget.destination);
    } else {
      _detectCurrentLocation(silent: true);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Dynamic Spots Generator around searched location ──────────────────
  List<SearchParkingSpot> _generateSpotsAround(LatLng center, String localityName) {
    final cleanName = localityName.trim().isNotEmpty ? localityName.trim() : 'Metro';
    return [
      SearchParkingSpot(
        id: 'spot_1',
        name: '$cleanName Metro & Grand Bay',
        area: '$cleanName Central',
        distanceKm: 0.2,
        ratePerHour: 50,
        isCovered: true,
        hasCctv: true,
        isVerified: true,
        position: LatLng(center.latitude + 0.0028, center.longitude + 0.0021),
        availableBays: 6,
      ),
      SearchParkingSpot(
        id: 'spot_2',
        name: '$cleanName Commercial Plaza Lot',
        area: '$cleanName Main Road',
        distanceKm: 0.5,
        ratePerHour: 40,
        isCovered: true,
        hasCctv: true,
        isVerified: true,
        position: LatLng(center.latitude - 0.0035, center.longitude + 0.0042),
        availableBays: 4,
      ),
      SearchParkingSpot(
        id: 'spot_3',
        name: '$cleanName Safe Basement Garage',
        area: '$cleanName West Sector',
        distanceKm: 0.8,
        ratePerHour: 35,
        isCovered: true,
        hasCctv: true,
        isVerified: true,
        position: LatLng(center.latitude + 0.0052, center.longitude - 0.0031),
        availableBays: 11,
      ),
      SearchParkingSpot(
        id: 'spot_4',
        name: '$cleanName Premium Covered Slot',
        area: '$cleanName Junction',
        distanceKm: 1.1,
        ratePerHour: 60,
        isCovered: true,
        hasCctv: true,
        isVerified: true,
        position: LatLng(center.latitude - 0.0022, center.longitude - 0.0048),
        availableBays: 2,
      ),
    ];
  }

  // ── Auto-Detect Device Location via GPS ────────────────────────────────
  Future<void> _detectCurrentLocation({bool silent = false}) async {
    setState(() => _isDetectingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Location permission is permanently denied. Please enable it in device settings.'),
            ),
          );
        }
        setState(() => _isDetectingGps = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      String detectedArea = 'My Location';

      // Reverse geocode via Nominatim to extract real locality/area name
      try {
        final dio = Dio();
        final res = await dio.get(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
          options: Options(headers: {
            'User-Agent': 'ParkSync-India-Mobile/1.0 (contact@parksync.app)',
          }),
        );
        if (res.data != null && res.data['address'] != null) {
          final addr = res.data['address'];
          detectedArea = addr['suburb'] ??
              addr['neighbourhood'] ??
              addr['city_district'] ??
              addr['city'] ??
              addr['town'] ??
              'My Location';
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _userDeviceLocation = userLatLng;
          _mapCenter = userLatLng;
          _searchedDestinationTitle = detectedArea;
          _searchedDestinationLatLng = userLatLng;
          _searchCtrl.text = detectedArea;
          _nearbySpots = _generateSpotsAround(userLatLng, detectedArea);
          _selectedSpotId = _nearbySpots.first.id;
          _isDetectingGps = false;
        });

        _mapController.move(userLatLng, 15.5);

        if (!silent) {
          SweetPopup.show(
            context,
            title: 'Location Detected',
            message: 'Auto-detected: $detectedArea',
            icon: Icons.my_location_rounded,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingGps = false);
        if (!silent) {
          SweetPopup.show(
            context,
            title: 'Location Error',
            message: 'Could not auto-detect location: $e',
            icon: Icons.location_off_rounded,
            iconColor: AppTheme.error,
          );
        }
      }
    }
  }

  // ── OpenStreetMap Nominatim Geocoding Search ──────────────────────────
  Future<void> _searchOpenStreetMap(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    setState(() {
      _isSearchingLocation = true;
      _osmSearchResults.clear();
    });

    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cleanQuery)}&format=json&addressdetails=1&limit=5';
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(headers: {
          'User-Agent': 'ParkSync-India-Mobile/1.0 (contact@parksync.app)',
        }),
      );

      if (response.data is List && (response.data as List).isNotEmpty) {
        final List data = response.data;
        final first = data.first;
        final lat = double.tryParse(first['lat'].toString()) ?? _mapCenter.latitude;
        final lon = double.tryParse(first['lon'].toString()) ?? _mapCenter.longitude;
        final displayName = first['display_name'] ?? cleanQuery;

        final parts = displayName.toString().split(',');
        final shortTitle = parts.length > 1
            ? '${parts[0].trim()}, ${parts[1].trim()}'
            : parts.first.trim();
        final localityKey = parts.first.trim();

        final target = LatLng(lat, lon);

        if (mounted) {
          setState(() {
            _mapCenter = target;
            _searchedDestinationTitle = shortTitle;
            _searchedDestinationLatLng = target;
            _nearbySpots = _generateSpotsAround(target, localityKey);
            _selectedSpotId = _nearbySpots.first.id;
            _osmSearchResults = data.map((item) => {
                  'name': item['display_name'] ?? '',
                  'lat': double.tryParse(item['lat'].toString()) ?? lat,
                  'lon': double.tryParse(item['lon'].toString()) ?? lon,
                }).toList();
            _isSearchingLocation = false;
          });
          _mapController.move(target, 15.0);
        }
      } else {
        // Even if Nominatim had no remote matches, dynamically anchor around current center with searched name!
        if (mounted) {
          setState(() {
            _searchedDestinationTitle = cleanQuery;
            _searchedDestinationLatLng = _mapCenter;
            _nearbySpots = _generateSpotsAround(_mapCenter, cleanQuery);
            _selectedSpotId = _nearbySpots.first.id;
            _isSearchingLocation = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchedDestinationTitle = cleanQuery;
          _searchedDestinationLatLng = _mapCenter;
          _nearbySpots = _generateSpotsAround(_mapCenter, cleanQuery);
          _selectedSpotId = _nearbySpots.first.id;
          _isSearchingLocation = false;
        });
      }
    }
  }

  // ── Zoom In / Zoom Out Controls ───────────────────────────────────────
  void _zoomIn() {
    try {
      final currentZoom = _mapController.camera.zoom;
      if (currentZoom < 18.0) {
        _mapController.move(_mapController.camera.center, currentZoom + 1.0);
      }
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final currentZoom = _mapController.camera.zoom;
      if (currentZoom > 3.0) {
        _mapController.move(_mapController.camera.center, currentZoom - 1.0);
      }
    } catch (_) {}
  }

  List<SearchParkingSpot> get _displayedSpots {
    return _nearbySpots.where((spot) {
      if (_filterCovered && !spot.isCovered) return false;
      if (_filterCctv && !spot.hasCctv) return false;
      return true;
    }).toList();
  }

  void _showFilters() {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? l.filters : 'Filters',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(
                      isEn ? l.compatibleWithMyVehicle : 'Compatible with my vehicle',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: _filterCompatible,
                    onChanged: (val) {
                      setSheetState(() => _filterCompatible = val);
                      setState(() => _filterCompatible = val);
                    },
                    activeThumbColor: AppTheme.cyan,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text(
                      isEn ? l.coveredParking : 'Covered Parking',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: _filterCovered,
                    onChanged: (val) {
                      setSheetState(() => _filterCovered = val);
                      setState(() => _filterCovered = val);
                    },
                    activeThumbColor: AppTheme.cyan,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text(
                      isEn ? l.cctvSurveillance : 'CCTV Surveillance',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: _filterCctv,
                    onChanged: (val) {
                      setSheetState(() => _filterCctv = val);
                      setState(() => _filterCctv = val);
                    },
                    activeThumbColor: AppTheme.cyan,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isEn ? l.applyFilters : 'Apply Filters'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = _displayedSpots;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build OpenStreetMap markers
    final markers = <Marker>[
      // 1. Device GPS user location marker
      if (_userDeviceLocation != null)
        Marker(
          point: _userDeviceLocation!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cyan.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.cyan, width: 2.5),
            ),
            child: const Center(
              child: Icon(Icons.my_location_rounded, color: AppTheme.cyan, size: 22),
            ),
          ),
        ),

      // 2. Searched Destination pin (Exact searched location)
      if (_searchedDestinationLatLng != null)
        Marker(
          point: _searchedDestinationLatLng!,
          width: 170,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _searchedDestinationTitle ?? 'Destination',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFEF4444), size: 18),
            ],
          ),
        ),

      // 3. Nearby Parking Spot Markers with dynamic pricing tags
      ...spots.map((spot) {
        final isSelected = _selectedSpotId == spot.id;

        return Marker(
          point: spot.position,
          width: isSelected ? 110 : 96,
          height: 52,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedSpotId = spot.id);
              _mapController.move(spot.position, 16.0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.forestGreen
                    : (isDark ? AppTheme.forestSurface : AppTheme.butterCream),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppTheme.butter : AppTheme.forestGreen,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppTheme.forestGreen.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_parking_rounded,
                    color: isSelected ? AppTheme.butter : AppTheme.forestGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${spot.ratePerHour.toInt()}/h',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isSelected ? AppTheme.butter : (isDark ? AppTheme.butter : AppTheme.forestGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── 1. OpenStreetMap (OSM) Live Tile Layer ────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 14.5,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parksync.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // OSM Attribution Badge
          Positioned(
            right: 8,
            top: MediaQuery.paddingOf(context).top + 130,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ),
          ),

          // ── 2. Top Interactive OpenStreetMap Search Bar + Auto-detect Chip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NeumorphicIconBadge(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 44,
                        iconSize: 18,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeumorphicCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          radius: 16,
                          child: Row(
                            children: [
                              if (_isSearchingLocation)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.forestGreen),
                                )
                              else
                                const Icon(Icons.search_rounded, size: 20, color: AppTheme.forestGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search city, landmark, or area (OSM)...',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).colorScheme.outline,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onSubmitted: (val) => _searchOpenStreetMap(val),
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _osmSearchResults.clear());
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.forestGreen),
                                tooltip: 'Search location on OpenStreetMap',
                                onPressed: () => _searchOpenStreetMap(_searchCtrl.text),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeumorphicIconBadge(
                        icon: Icons.tune_rounded,
                        size: 44,
                        iconSize: 20,
                        iconColor: AppTheme.forestGreen,
                        onTap: _showFilters,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Quick Auto-Detect Location Pill Button
                  Row(
                    children: [
                      const SizedBox(width: 52),
                      NeumorphicCard(
                        onTap: _isDetectingGps ? null : () => _detectCurrentLocation(),
                        radius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isDetectingGps)
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.forestGreen),
                              )
                            else
                              const Icon(Icons.my_location_rounded, size: 13, color: AppTheme.forestGreen),
                            const SizedBox(width: 6),
                            Text(
                              _isDetectingGps ? 'Detecting GPS location...' : 'Auto-detect my location',
                              style: TextStyle(
                                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // OpenStreetMap Instant Nominatim Suggestions Dropdown
                  if (_osmSearchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 48, right: 48),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _osmSearchResults.map((item) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.cyan),
                            title: Text(
                              item['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              final lat = item['lat'];
                              final lon = item['lon'];
                              final target = LatLng(lat, lon);
                              final rawName = item['name'].toString();
                              final parts = rawName.split(',');
                              final shortName = parts.length > 1
                                  ? '${parts[0].trim()}, ${parts[1].trim()}'
                                  : parts.first.trim();

                              setState(() {
                                _mapCenter = target;
                                _searchedDestinationTitle = shortName;
                                _searchedDestinationLatLng = target;
                                _searchCtrl.text = shortName;
                                _nearbySpots = _generateSpotsAround(target, parts.first.trim());
                                _selectedSpotId = _nearbySpots.first.id;
                                _osmSearchResults.clear();
                              });
                              _mapController.move(target, 15.5);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── 3. Floating Map Controls (Zoom In/Out + Auto-Detect GPS) ────
          Positioned(
            right: 14,
            bottom: 236, // Placed directly above the parking cards carousel
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Auto-Detect Current GPS Location Button
                _buildMapFloatingButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Auto-detect my location',
                  onPressed: _isDetectingGps ? null : () => _detectCurrentLocation(),
                  isAccent: true,
                  isLoading: _isDetectingGps,
                ),
                const SizedBox(height: 12),
                // Zoom In (+) Button
                _buildMapFloatingButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom in',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 6),
                // Zoom Out (-) Button
                _buildMapFloatingButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom out',
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),

          // ── 4. Bottom Parking Carousel Cards ──────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                height: 220,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading showing matching spots count and destination
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${spots.length} bays available near ${_searchedDestinationTitle ?? 'area'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Cards list
                    Expanded(
                      child: spots.isEmpty
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                                ),
                              ),
                              child: const Center(
                                child: Text('No parking bays match the active filters.'),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: spots.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final spot = spots[index];
                                final isSelected = _selectedSpotId == spot.id;
                                return _buildSearchCard(context, spot, isDark, isSelected);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isAccent = false,
    bool isLoading = false,
  }) {
    return NeumorphicIconBadge(
      icon: icon,
      size: 46,
      iconSize: 22,
      iconColor: isAccent
          ? (Theme.of(context).brightness == Brightness.dark ? AppTheme.butter : AppTheme.forestGreen)
          : Theme.of(context).colorScheme.primary,
      onTap: onPressed,
    );
  }

  Widget _buildSearchCard(BuildContext context, SearchParkingSpot spot, bool isDark, bool isSelected) {
    return SizedBox(
      width: 290,
      child: NeumorphicCard(
        radius: 18,
        padding: const EdgeInsets.all(14.0),
        onTap: () {
          setState(() => _selectedSpotId = spot.id);
          _mapController.move(spot.position, 16.0);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    spot.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${spot.ratePerHour.toInt()}/hr',
                  style: TextStyle(
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '${spot.distanceKm} km away • ${spot.area}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 11,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${spot.availableBays} bays free ✓',
                        style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                NeumorphicButton(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  onPressed: () => context.push('/parking-detail', extra: spot.id),
                  child: const Text('Book Spot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (spot.isCovered) _buildChip('Covered Bay'),
                const SizedBox(width: 6),
                if (spot.hasCctv) _buildChip('CCTV 24/7'),
                const SizedBox(width: 6),
                _buildChip('Host Verified ✓'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
