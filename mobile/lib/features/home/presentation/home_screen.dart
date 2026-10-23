import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../core/api_client.dart';
import '../../../core/locale_provider.dart';
import '../../../core/theme_provider.dart';
import '../../../core/user_state_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocationText = 'Detecting GPS location...';
  String _vehicleDisplay = 'Standard Passenger Car / SUV';
  bool _isLocating = false;
  int _navIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';
  final Set<String> _savedSpotIds = {};

  List<Map<String, dynamic>> _spots = [];
  bool _isLoadingSpots = true;
  List<Map<String, dynamic>> _userBookings = [];
  bool _isLoadingBookings = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _loadSavedVehicle();
    _fetchSpots();
    _fetchBookings();
  }

  Future<void> _fetchSpots() async {
    setState(() => _isLoadingSpots = true);
    try {
      final response = await ApiClient().dio.get('/parking');
      if (response.data is List) {
        final list = (response.data as List).map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final hostName = map['provider']?['displayName'] ??
              map['provider']?['user']?['name'] ??
              'Authorized Host';
          final totalBays = map['totalBays'] ?? 1;
          final availBays = map['availableBays'] ?? totalBays;
          return {
            'id': map['id']?.toString() ?? '',
            'name': map['title']?.toString() ?? 'ParkSync Bay',
            'area': map['area']?.toString() ?? map['city']?.toString() ?? 'Central Hub',
            'city': map['city']?.toString() ?? '',
            'address': map['address']?.toString() ?? '',
            'distance': '0.5',
            'rate': (map['pricePerHour'] as num?)?.round() ?? 40,
            'covered': map['covered'] == true,
            'cctv': map['cctv'] == true,
            'security': map['security'] == true,
            'verified': true,
            'available': availBays,
            'total': totalBays,
            'hostName': hostName,
            'spaceType': map['spaceType']?.toString() ?? 'Standard Bay',
          };
        }).toList();

        if (mounted) {
          setState(() {
            _spots = list;
            _isLoadingSpots = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('[HomeScreen] Fetch spots error: $e');
    }
    if (mounted) {
      setState(() => _isLoadingSpots = false);
    }
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoadingBookings = true);
    try {
      final response = await ApiClient().dio.get('/bookings/my-bookings');
      if (response.data is List && mounted) {
        setState(() {
          _userBookings = (response.data as List)
              .map((b) => Map<String, dynamic>.from(b as Map))
              .toList();
          _isLoadingBookings = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[HomeScreen] Fetch bookings error: $e');
    }
    if (mounted) {
      setState(() => _isLoadingBookings = false);
    }
  }

  Future<void> _loadSavedVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('selected_vehicle_name');
    final reg = prefs.getString('selected_vehicle_reg');
    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        _vehicleDisplay = reg != null && reg.isNotEmpty ? '$name ($reg)' : name;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _currentLocationText = 'Tap to enable GPS location';
            _isLocating = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      if (mounted) {
        setState(() {
          _currentLocationText =
              'GPS: ${position.latitude.toStringAsFixed(3)}°N, ${position.longitude.toStringAsFixed(3)}°E (Auto)';
          _isLocating = false;
        });

        SweetPopup.show(
          context,
          title: 'Location Updated',
          message: 'GPS synced to your current coordinates.',
          icon: Icons.my_location_rounded,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentLocationText = 'Near Your Current Area';
          _isLocating = false;
        });
      }
    }
  }

  void _toggleSaveSpot(String spotId, String spotName) {
    setState(() {
      if (_savedSpotIds.contains(spotId)) {
        _savedSpotIds.remove(spotId);
        SweetPopup.show(
          context,
          title: 'Removed from Favorites',
          message: '$spotName removed from your saved spots.',
          icon: Icons.bookmark_remove_rounded,
          iconColor: Colors.grey,
        );
      } else {
        _savedSpotIds.add(spotId);
        SweetPopup.show(
          context,
          title: 'Saved to Favorites!',
          message: '$spotName added to your favorite parking bays.',
          icon: Icons.bookmark_added_rounded,
          iconColor: AppTheme.amber,
        );
      }
    });
  }

  List<Map<String, dynamic>> get _filteredSpots {
    final q = _searchCtrl.text.toLowerCase().trim();
    return _spots.where((s) {
      if (q.isNotEmpty) {
        final name = s['name'].toString().toLowerCase();
        final area = s['area'].toString().toLowerCase();
        if (!name.contains(q) && !area.contains(q)) return false;
      }
      if (_selectedFilter == 'Covered' && s['covered'] != true) return false;
      if (_selectedFilter == 'CCTV' && s['cctv'] != true) return false;
      if (_selectedFilter == 'Under ₹40' && (s['rate'] as int) > 40) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Fixed Top Neumorphic AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 2, blur: 6),
            ),
            child: Row(
              children: [
                NeumorphicIconBadge(
                  icon: Icons.local_parking_rounded,
                  size: 40,
                  iconSize: 22,
                  color: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'ParkSync',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Spacer(),

                // Theme Mode Switcher
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: appThemeMode,
                  builder: (context, mode, _) {
                    final isNight = mode == ThemeMode.dark;
                    return NeumorphicIconBadge(
                      icon: isNight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 38,
                      iconSize: 19,
                      iconColor: isNight ? AppTheme.amber : AppTheme.forestGreen,
                      onTap: () {
                        toggleThemeMode();
                        SweetPopup.show(
                          context,
                          title: isNight ? 'Bright Mode Enabled' : 'Night Mode Enabled',
                          message: isNight ? 'Warm butter theme activated.' : 'Deep forest theme activated.',
                          icon: isNight ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Language switcher
                NeumorphicIconBadge(
                  icon: Icons.language_rounded,
                  size: 38,
                  iconSize: 19,
                  onTap: () => _showLanguageModal(context),
                ),

                const SizedBox(width: 8),

                // Profile Avatar Button
                InkWell(
                  onTap: () => setState(() => _navIndex = 3),
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 4 Functional Tabs
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildExploreView(context, isEn, isDark),
          _buildSavedView(context, isDark),
          _buildBookingsView(context, isDark),
          _buildProfileView(context, isDark),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 3, blur: 8),
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: isEn ? l.explore : 'Explore',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_outline_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: isEn ? l.saved : 'Saved',
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: isEn ? l.bookings : 'Bookings',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: isEn ? l.profile : 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreView(BuildContext context, bool isEn, bool isDark) {
    final spots = _filteredSpots;

    return RefreshIndicator(
      onRefresh: _fetchSpots,
      color: AppTheme.forestGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto GPS / Location Neumorphic Card
          NeumorphicCard(
            onTap: _fetchLocation,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            radius: 16,
            child: Row(
              children: [
                _isLocating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                        ),
                      )
                    : Icon(Icons.my_location_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentLocationText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Auto-detect',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Active Booking Card (Neumorphic)
          _ActiveBookingCard(
            onTap: () {
              context.push('/capture-evidence',
                  extra: {'bookingId': 'bk_live_01', 'type': 'BEFORE'});
            },
          ),

          const SizedBox(height: 22),

          // Interactive Search Bar (Typing works directly)
          NeumorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            radius: 18,
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where are you driving to?',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => setState(() {}),
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
                InkWell(
                  onTap: () => context.push('/search', extra: _searchCtrl.text),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.map_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', isDark),
                _buildFilterChip('Covered', isDark),
                _buildFilterChip('CCTV', isDark),
                _buildFilterChip('Under ₹40', isDark),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vehicle Selector Pill
          ListenableBuilder(
            listenable: UserStateService.instance,
            builder: (context, _) {
              final activeVehicle = UserStateService.instance.activeVehicle;
              final vehicleTitle = activeVehicle != null
                  ? '${activeVehicle.make} ${activeVehicle.model} (${activeVehicle.plateNumber})'
                  : _vehicleDisplay;

              return NeumorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                radius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.directions_car_rounded,
                          color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Vehicle Fit',
                              style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11)),
                          Text(vehicleTitle,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/add-vehicle'),
                      child: Text('Change',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Nearby Spots Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Bays (${spots.length})',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () => context.push('/search', extra: ''),
                child: Text('Open Map View',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Spots List with Real-time Loading & Empty States
          if (_isLoadingSpots) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
              ),
            ),
          ] else if (spots.isEmpty) ...[
            NeumorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              radius: 18,
              child: Column(
                children: [
                  Icon(Icons.local_parking_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  const Text(
                    'No Live Parking Spaces Yet',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first parking owner to list your bay or driveway and start earning!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: AppTheme.butter,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/provider-onboarding'),
                    icon: const Icon(Icons.add_business_rounded, size: 18),
                    label: const Text('List a Parking Space'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final spot = spots[i];
                final isSaved = _savedSpotIds.contains(spot['id']);
                return _HomeSpotCard(
                  spot: spot,
                  isSaved: isSaved,
                  onTap: () => context.push('/parking-detail', extra: spot['id']),
                  onToggleSave: () => _toggleSaveSpot(spot['id'], spot['name']),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : (isDark ? AppTheme.forestSurface : AppTheme.butterCream),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? AppTheme.neumorphicPressedShadows(isDark: isDark)
                : AppTheme.neumorphicShadows(isDark: isDark, distance: 2.5, blur: 6),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedView(BuildContext context, bool isDark) {
    final savedList = _spots.where((s) => _savedSpotIds.contains(s['id'])).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Parking Bays', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Your favorite parking bays for instant reservation.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Expanded(
            child: savedList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded,
                            size: 56, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 12),
                        Text('No saved parking spots yet.',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.outline)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: savedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final spot = savedList[i];
                      return _HomeSpotCard(
                        spot: spot,
                        isSaved: true,
                        onTap: () => context.push('/parking-detail', extra: spot['id']),
                        onToggleSave: () => _toggleSaveSpot(spot['id'], spot['name']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsView(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.forestGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Reservations (${_userBookings.length})',
                    style: Theme.of(context).textTheme.displayMedium),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Bookings',
                  onPressed: _fetchBookings,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time booking requests, host confirmation status, and parking passes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            if (_isLoadingBookings) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
                ),
              ),
            ] else if (_userBookings.isEmpty) ...[
              NeumorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                radius: 18,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    const Text(
                      'No Reservations Yet',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search and reserve parking bays near your travel destination in advance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: AppTheme.butter,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _navIndex = 0),
                      child: const Text('Explore Nearby Spots'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final b = _userBookings[i];
                  final status = (b['status'] ?? 'PENDING').toString().toUpperCase();
                  final ref = b['bookingReference'] ?? 'BK-REQ';
                  final space = b['parkingSpace'] ?? {};
                  final spaceTitle = space['title'] ?? 'ParkSync Bay';
                  final address = space['address'] ?? '';
                  final amount = '₹${b['totalAmount'] ?? '40.0'}';
                  final paymentMethod = b['paymentMethod'] == 'UPI' ? 'UPI' : 'Cash on Arrival';
                  final hostName = b['hostName'] ?? 'Authorized Host';
                  final hostPhone = b['hostPhone'] ?? 'Contact upon confirmation';

                  Color statusColor = AppTheme.amber;
                  String statusLabel = 'Awaiting Host Approval';
                  IconData statusIcon = Icons.hourglass_top_rounded;

                  if (status == 'CONFIRMED' || status == 'ACTIVE') {
                    statusColor = AppTheme.success;
                    statusLabel = 'Host Approved ● Ready';
                    statusIcon = Icons.check_circle_rounded;
                  } else if (status == 'REJECTED') {
                    statusColor = AppTheme.error;
                    statusLabel = 'Request Declined';
                    statusIcon = Icons.cancel_rounded;
                  } else if (status == 'COMPLETED') {
                    statusColor = Colors.blue;
                    statusLabel = 'Completed';
                    statusIcon = Icons.task_alt_rounded;
                  }

                  return NeumorphicCard(
                    padding: const EdgeInsets.all(16),
                    radius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REF: #$ref',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 12, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spaceTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$amount • $paymentMethod',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (status == 'CONFIRMED' || status == 'ACTIVE')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Slot Reserved',
                                  style: TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Host details & privacy
                        Row(
                          children: [
                            Icon(
                              (status == 'CONFIRMED' || status == 'ACTIVE')
                                  ? Icons.phone_in_talk_rounded
                                  : Icons.lock_outline_rounded,
                              size: 16,
                              color: (status == 'CONFIRMED' || status == 'ACTIVE')
                                  ? AppTheme.success
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (status == 'CONFIRMED' || status == 'ACTIVE')
                                    ? 'Host: $hostName ($hostPhone)'
                                    : 'Host: $hostName (Phone hidden for privacy until approved)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (status == 'CONFIRMED' || status == 'ACTIVE')
                                      ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Header Card
          ListenableBuilder(
            listenable: UserStateService.instance,
            builder: (context, _) {
              final user = UserStateService.instance;
              return NeumorphicCard(
                padding: const EdgeInsets.all(18),
                radius: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      child: Icon(Icons.person_rounded, size: 32, color: primaryColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.userName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.phoneNumber.isNotEmpty
                                ? '${user.phoneNumber} • Verified Seeker'
                                : 'Verified Driver Account',
                            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Appearance & Preferences',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),

          // Theme Switcher Tile (Neumorphic)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, _) {
              final isNight = mode == ThemeMode.dark;
              return NeumorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                radius: 16,
                child: Row(
                  children: [
                    Icon(
                      isNight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isNight ? AppTheme.amber : AppTheme.forestGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dark Appearance',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(
                            isNight ? 'Active (Deep Forest Green)' : 'Inactive (Warm Butter Palette)',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isNight,
                      activeThumbColor: AppTheme.butter,
                      activeTrackColor: AppTheme.forestGreenLight,
                      inactiveThumbColor: AppTheme.forestGreen,
                      inactiveTrackColor: AppTheme.butterCream,
                      onChanged: (val) {
                        toggleThemeMode();
                        SweetPopup.show(
                          context,
                          title: val ? 'Dark Appearance Activated' : 'Light Appearance Activated',
                          message: val ? 'Forest palette enabled.' : 'Butter palette enabled.',
                          icon: val ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          NeumorphicCard(
            onTap: () => _showLanguageModal(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: primaryColor, size: 22),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('App Language',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Text(
                  appLocale.value.languageCode == 'mr'
                      ? 'मराठी'
                      : appLocale.value.languageCode == 'hi'
                          ? 'हिंदी'
                          : 'English',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // User Guide Tile
          NeumorphicCard(
            onTap: () => context.push('/user-guide', extra: 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: primaryColor, size: 22),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ParkSync User Guide & Manual',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Driver walkthrough & reservation instructions',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Privacy Policy Tile
          NeumorphicCard(
            onTap: () => context.push('/privacy-policy', extra: 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: Row(
              children: [
                Icon(Icons.policy_rounded, color: primaryColor, size: 22),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Privacy Policy & Terms',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('DPDP Act 2023 compliance & data rights',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),


          const SizedBox(height: 12),

          // Logout Tile
          NeumorphicCard(
            onTap: () async {
              await UserStateService.instance.logout();
              if (context.mounted) {
                SweetPopup.show(
                  context,
                  title: 'Logged Out',
                  message: 'You have been safely signed out.',
                  icon: Icons.check_circle_rounded,
                );
                context.go('/login');
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
                SizedBox(width: 14),
                Expanded(
                  child: Text('Log Out',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Language / भाषा निवडा',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                title: const Text('English', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: appLocale.value.languageCode == 'en'
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('en');
                  Navigator.pop(context);
                  SweetPopup.show(context, message: 'Language updated to English.');
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                title: const Text('मराठी (Marathi)', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: appLocale.value.languageCode == 'mr'
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('mr');
                  Navigator.pop(context);
                  SweetPopup.show(context, message: 'भाषा मराठी मध्ये बदलली आहे.');
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                title: const Text('हिंदी (Hindi)', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: appLocale.value.languageCode == 'hi'
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('hi');
                  Navigator.pop(context);
                  SweetPopup.show(context, message: 'भाषा हिन्दी में बदल दी गई है।');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveBookingCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ActiveBookingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.forestElevated : AppTheme.forestGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 5, blur: 14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.butter.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_parking_rounded, color: AppTheme.butter, size: 26),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors_rounded, color: AppTheme.butter, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'ACTIVE PASS #BK-492',
                        style: TextStyle(
                          color: AppTheme.butter,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bay A4 • Spot Reserved',
                    style: TextStyle(
                      color: AppTheme.butter,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to capture security evidence photo',
                    style: TextStyle(
                      color: Color(0xFFD3E5E0),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.butter.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.butter, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSpotCard extends StatelessWidget {
  final Map<String, dynamic> spot;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const _HomeSpotCard({
    required this.spot,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return NeumorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_parking_rounded, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot['name'] ?? 'ParkSync Bay',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${spot['available']} / ${spot['total'] ?? spot['available']} bays free • ${spot['area'] ?? ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Host: ${spot['hostName'] ?? 'Verified Host'}',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (spot['covered'] == true) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Covered',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (spot['cctv'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CCTV',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.success),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${spot['rate']}/hr',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onToggleSave,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSaved
                        ? AppTheme.amber.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    size: 16,
                    color: isSaved ? AppTheme.amber : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
