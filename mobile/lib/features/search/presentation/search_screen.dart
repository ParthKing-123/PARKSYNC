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
  // Default Central India coordinate fallback
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777), // National Hub
    zoom: 13.5,
  );

  GoogleMapController? _mapController;
  bool _isMapReady = false;
  LatLng _userPosition = const LatLng(19.0760, 72.8777);

  @override
  void initState() {
    super.initState();
    _initUserLocation();
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

  void _showFilters() {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                value: true,
                onChanged: (val) {},
                activeThumbColor: AppTheme.cyan,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(
                  isEn ? l.coveredParking : 'Covered Parking',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                value: false,
                onChanged: (val) {},
                activeThumbColor: AppTheme.cyan,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(
                  isEn ? l.cctvSurveillance : 'CCTV Surveillance',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                value: true,
                onChanged: (val) {},
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
  }

  // Generic national mock parking spots
  static final List<Map<String, dynamic>> _searchResults = [
    {
      'id': 'p1',
      'name': 'Metro Bay Central',
      'distance': '0.3',
      'rate': '50',
      'covered': true,
      'cctv': true,
      'verified': true,
    },
    {
      'id': 'p2',
      'name': 'City Square Parking',
      'distance': '1.2',
      'rate': '40',
      'covered': true,
      'cctv': true,
      'verified': true,
    },
    {
      'id': 'p3',
      'name': 'Grand Tower Multi-level',
      'distance': '2.1',
      'rate': '30',
      'covered': false,
      'cctv': true,
      'verified': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
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
                infoWindow: const InfoWindow(title: 'Metro Bay Central • ₹50/hr'),
              ),
            },
          ),

          // Fallback if Map tiles are waiting or key not active
          if (!_isMapReady)
            Container(
              color: AppTheme.bgBase,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.1),
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
                      'Map Radar Active',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Searching parking bays near your area',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

          // 2. Top Search & Filter Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.bgSurface,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      onPressed: () => context.pop(),
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1C2A42)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: AppTheme.cyan),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.destination.isEmpty
                                  ? 'Search destination'
                                  : widget.destination,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: AppTheme.bgSurface,
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
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final spot = _searchResults[index];
                    return _buildSearchCard(context, spot);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, Map<String, dynamic> spot) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1C2A42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
                    style: const TextStyle(
                      color: AppTheme.cyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${spot['distance']} km away',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 13, color: AppTheme.cyan),
                    SizedBox(width: 4),
                    Text(
                      'Compatible with your vehicle',
                      style: TextStyle(
                        color: AppTheme.cyan,
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
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
