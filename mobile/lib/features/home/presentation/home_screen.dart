import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parksync/l10n/app_localizations.dart';
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
  final Set<String> _savedSpotIds = {'p1', 'p2'};

  final List<Map<String, dynamic>> _spots = [
    {
      'id': 'p1',
      'name': 'Metro Grand Parking Bay',
      'area': 'Station Central Hub',
      'distance': '0.3',
      'rate': 50,
      'covered': true,
      'cctv': true,
      'verified': true,
      'available': 4,
    },
    {
      'id': 'p2',
      'name': 'Central Commercial Plaza',
      'area': 'Business District',
      'distance': '1.1',
      'rate': 40,
      'covered': true,
      'cctv': true,
      'verified': true,
      'available': 12,
    },
    {
      'id': 'p3',
      'name': 'Tech Hub Multi-Level Lot',
      'area': 'Cyber Park Avenue',
      'distance': '2.0',
      'rate': 30,
      'covered': false,
      'cctv': true,
      'verified': true,
      'available': 8,
    },
    {
      'id': 'p4',
      'name': 'Station Road Secure Bay',
      'area': 'Terminal North Gate',
      'distance': '3.2',
      'rate': 25,
      'covered': true,
      'cctv': false,
      'verified': true,
      'available': 18,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _loadSavedVehicle();
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

    return SingleChildScrollView(
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

          // Spots List
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
          const SizedBox(height: 24),
        ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Reservations', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Active parking passes, QR entry codes, and receipts.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          _ActiveBookingCard(
            onTap: () {
              context.push('/capture-evidence',
                  extra: {'bookingId': 'bk_live_01', 'type': 'BEFORE'});
            },
          ),
        ],
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

          const SizedBox(height: 24),
          Text('Partner with ParkSync',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),

          // Switch / Register Host Tile
          NeumorphicCard(
            onTap: () async {
              if (UserStateService.instance.isProviderRegistered) {
                await UserStateService.instance.switchRole(UserRole.provider);
                if (context.mounted) {
                  context.go('/provider-home');
                }
              } else {
                context.push('/provider-onboarding');
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppTheme.success, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UserStateService.instance.isProviderRegistered
                            ? 'Switch to Host Dashboard'
                            : 'Become a Parking Host',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        UserStateService.instance.isProviderRegistered
                            ? 'Manage your bays, rates & earnings'
                            : 'Monetize vacant driveway or commercial lot',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
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
                  spot['name'],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${spot['distance']} km away • ${spot['available']} bays free',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
