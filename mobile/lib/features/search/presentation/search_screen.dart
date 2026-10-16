import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String destination;
  const SearchScreen({super.key, required this.destination});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777), // Central Hub
    zoom: 13.5,
  );

  GoogleMapController? _mapController;
  bool _isMapReady = false;
  LatLng _userPosition = const LatLng(19.0760, 72.8777);
  late TextEditingController _searchCtrl;

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
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.destination);
    _initUserLocation();
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
        setState(() {
          _userPosition = LatLng(pos.latitude, pos.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_userPosition, 14.0),
        );
      }
    } catch (_) {}
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _defaultPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              setState(() => _isMapReady = true);
            },
            markers: {
              Marker(
                markerId: const MarkerId('m1'),
                position: _userPosition,
                infoWindow: const InfoWindow(title: 'Metro Grand Parking Bay • ₹50/hr'),
              ),
            },
          ),

          // Fallback if Map tiles are waiting or key not active
          if (!_isMapReady)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        size: 48,
                        color: AppTheme.cyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Live Parking Radar',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scanning nearby parking bays for ${_searchCtrl.text.isEmpty ? "your area" : _searchCtrl.text}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

          // 2. Top Search & Filter Bar (Editable TextField!)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
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
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
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
                                hintText: 'Enter destination or area...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (val) {
                                setState(() {});
                              },
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
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
            ),
          ),

          // 3. Bottom Carousel Cards
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
                      Icons.check_circle_rounded,
                      size: 13,
                      color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Compatible with your vehicle',
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
