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
                    activeThumbColor: AppTheme.accentGold,
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
                    activeThumbColor: AppTheme.accentGold,
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
                    activeThumbColor: AppTheme.accentGold,
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
              color: (isDark ? AppTheme.accentGold : AppTheme.forestGreen).withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? AppTheme.accentGold : AppTheme.forestGreen, width: 2.5),
            ),
            child: Center(
              child: Icon(Icons.my_location_rounded, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen, size: 22),
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
        final bg = isSelected
            ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
            : (isDark ? const Color(0xFF143B33) : AppTheme.butterCream);
        final fg = isSelected
            ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
            : (isDark ? AppTheme.accentGold : AppTheme.forestGreen);
        final borderColor = isSelected
            ? (isDark ? AppTheme.accentGold : AppTheme.butter)
            : (isDark ? const Color(0xFF23695B) : AppTheme.borderLight);

        return Marker(
          point: spot.position,
          width: isSelected ? 116 : 102,
          height: 44,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedSpotId = spot.id);
              _mapController.move(spot.position, 16.0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter.withValues(alpha: 0.2))
                          : (isDark ? const Color(0xFF0D2520) : AppTheme.forestGreen.withValues(alpha: 0.12)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '₹${spot.ratePerHour.toInt()}/h',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: fg,
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
                        color: isDark ? null : AppTheme.butter,
                        iconColor: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeumorphicCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          radius: 16,
                          color: isDark ? null : AppTheme.butter,
                          child: Row(
                            children: [
                              if (_isSearchingLocation)
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search city, landmark, or area (OSM)...',
                                    hintStyle: TextStyle(
                                      color: isDark ? const Color(0xFFA5C9C1) : AppTheme.textMutedLight,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
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
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _osmSearchResults.clear());
                                  },
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                ),
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
                        color: isDark ? null : AppTheme.butter,
                        iconColor: isDark ? AppTheme.butter : AppTheme.forestGreen,
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
                        color: isDark ? null : AppTheme.butter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isDetectingGps)
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                ),
                              )
                            else
                              Icon(
                                Icons.my_location_rounded,
                                size: 13,
                                color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                              ),
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
                          color: Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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
                            leading: Icon(Icons.location_on_rounded, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
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
                                  color: Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NeumorphicIconBadge(
      icon: icon,
      size: 46,
      iconSize: 22,
      color: isDark ? null : AppTheme.butter,
      iconColor: isAccent
          ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
          : (isDark ? AppTheme.butter : AppTheme.forestGreen),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${spot.ratePerHour.toInt()}/hr',
                  style: TextStyle(
                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '${spot.distanceKm} km away • ${spot.area}',
              style: TextStyle(
                color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: isDark ? 0.22 : 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: isDark ? 0.45 : 0.25),
                    ),
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
                if (spot.isCovered) _buildChip('Covered Bay', isDark),
                const SizedBox(width: 6),
                if (spot.hasCctv) _buildChip('CCTV 24/7', isDark),
                const SizedBox(width: 6),
                _buildChip('Host Verified ✓', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF143B33) : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF23695B).withValues(alpha: 0.5) : AppTheme.borderLight,
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
