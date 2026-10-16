import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String destination;
  const SearchScreen({super.key, required this.destination});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Default to central India coordinates
  LatLng _mapCenter = const LatLng(20.5937, 78.9629); // India center
  final MapController _mapController = MapController();
  late TextEditingController _searchCtrl;
  bool _isSearchingLocation = false;
  List<Map<String, dynamic>> _osmSearchResults = [];

  // Filter switches
  bool _filterCompatible = true;
  bool _filterCovered = false;
  bool _filterCctv = false;

  final List<Map<String, dynamic>> _allSpots = [
    {
      'id': 'p1',
      'name': 'Metro Grand Parking Bay',
      'area': 'Station Central Hub',
      'distance': '0.3',
      'rate': 50,
      'covered': true,
      'cctv': true,
      'verified': true,
      'lat': 20.5937,
      'lng': 78.9629,
    },
    {
      'id': 'p2',
      'name': 'Central Commercial Plaza',
      'area': 'Business District',
      'distance': '1.2',
      'rate': 40,
      'covered': true,
      'cctv': true,
      'verified': true,
      'lat': 20.5980,
      'lng': 78.9680,
    },
    {
      'id': 'p3',
      'name': 'Tech Hub Multi-Level Lot',
      'area': 'Cyber Park Avenue',
      'distance': '2.1',
      'rate': 30,
      'covered': false,
      'cctv': true,
      'verified': true,
      'lat': 20.5890,
      'lng': 78.9570,
    },
    {
      'id': 'p4',
      'name': 'National Mall Basement Lot',
      'area': 'City Center Mall',
      'distance': '1.8',
      'rate': 35,
      'covered': true,
      'cctv': true,
      'verified': true,
      'lat': 20.6010,
      'lng': 78.9710,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.destination);
    _initUserLocation();
    if (widget.destination.isNotEmpty) {
      _searchOpenStreetMap(widget.destination);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null && mounted) {
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _mapCenter = userLatLng;
          // Dynamically anchor mock parking spots near user position
          _allSpots[0]['lat'] = pos.latitude + 0.003;
          _allSpots[0]['lng'] = pos.longitude + 0.002;
          _allSpots[1]['lat'] = pos.latitude - 0.004;
          _allSpots[1]['lng'] = pos.longitude + 0.005;
          _allSpots[2]['lat'] = pos.latitude + 0.006;
          _allSpots[2]['lng'] = pos.longitude - 0.003;
          _allSpots[3]['lat'] = pos.latitude - 0.002;
          _allSpots[3]['lng'] = pos.longitude - 0.005;
        });
        _mapController.move(userLatLng, 14.5);
      }
    } catch (_) {}
  }

  // ── OpenStreetMap Nominatim Geocoding Search (100% Free, No Billing) ──
  Future<void> _searchOpenStreetMap(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearchingLocation = true);

    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5';
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

        final newCenter = LatLng(lat, lon);
        if (mounted) {
          setState(() {
            _mapCenter = newCenter;
            _osmSearchResults = data.map((item) => {
              'name': item['display_name'] ?? '',
              'lat': double.tryParse(item['lat'].toString()) ?? lat,
              'lon': double.tryParse(item['lon'].toString()) ?? lon,
            }).toList();

            // Re-anchor spots near searched OSM location
            _allSpots[0]['lat'] = lat + 0.003;
            _allSpots[0]['lng'] = lon + 0.002;
            _allSpots[1]['lat'] = lat - 0.004;
            _allSpots[1]['lng'] = lon + 0.005;
            _allSpots[2]['lat'] = lat + 0.006;
            _allSpots[2]['lng'] = lon - 0.003;
            _allSpots[3]['lat'] = lat - 0.002;
            _allSpots[3]['lng'] = lon - 0.005;

            _isSearchingLocation = false;
          });
          _mapController.move(newCenter, 14.5);
        }
      } else {
        if (mounted) setState(() => _isSearchingLocation = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isSearchingLocation = false);
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    final q = _searchCtrl.text.toLowerCase().trim();
    return _allSpots.where((spot) {
      if (q.isNotEmpty) {
        final name = spot['name'].toString().toLowerCase();
        final area = spot['area'].toString().toLowerCase();
        if (!name.contains(q) && !area.contains(q)) return false;
      }
      if (_filterCovered && spot['covered'] != true) return false;
      if (_filterCctv && spot['cctv'] != true) return false;
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
    final results = _filteredResults;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build OpenStreetMap markers for parking bays
    final markers = <Marker>[
      // User / Searched center marker
      Marker(
        point: _mapCenter,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cyan.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.cyan, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.my_location_rounded, color: AppTheme.cyan, size: 22),
          ),
        ),
      ),
      // Parking spots markers
      ...results.map((spot) {
        final double lat = spot['lat'] ?? _mapCenter.latitude;
        final double lng = spot['lng'] ?? _mapCenter.longitude;

        return Marker(
          point: LatLng(lat, lng),
          width: 90,
          height: 44,
          child: GestureDetector(
            onTap: () => context.push('/parking-detail', extra: spot['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1420) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cyan, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_parking_rounded, color: AppTheme.cyan, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '₹${spot['rate']}/h',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black,
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
            top: MediaQuery.paddingOf(context).top + 80,
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

          // ── 2. Top Interactive OpenStreetMap Search Bar ───────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          onPressed: () => context.pop(),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (_isSearchingLocation)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan),
                                )
                              else
                                const Icon(Icons.search_rounded, size: 20, color: AppTheme.cyan),
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
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.cyan),
                                tooltip: 'Search location on OpenStreetMap',
                                onPressed: () => _searchOpenStreetMap(_searchCtrl.text),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 20),
                          onPressed: _showFilters,
                          color: AppTheme.cyan,
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
                              setState(() {
                                _mapCenter = target;
                                _searchCtrl.text = item['name'].toString().split(',').first;
                                _osmSearchResults.clear();
                              });
                              _mapController.move(target, 15.0);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── 3. Bottom Carousel Cards ──────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                height: 200,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: results.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('No parking spots found for this query.'),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final spot = results[index];
                          return _buildSearchCard(context, spot, isDark);
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, Map<String, dynamic> spot, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/parking-detail', extra: spot['id']),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      spot['name'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${spot['rate']}/hr',
                    style: TextStyle(
                      color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${spot['distance']} km away • ${spot['area']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Platform Verified Host ✓',
                      style: TextStyle(
                        color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (spot['covered'] == true) _buildChip('Covered'),
                  const SizedBox(width: 6),
                  if (spot['cctv'] == true) _buildChip('CCTV'),
                  const SizedBox(width: 6),
                  _buildChip('Verified ✓'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
