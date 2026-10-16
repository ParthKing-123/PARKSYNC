import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../core/locale_provider.dart';
import '../../../core/theme_provider.dart';
import '../../../shared/theme/app_theme.dart';

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
      'accent': AppTheme.cyan,
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
      'accent': AppTheme.violet,
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
      'accent': AppTheme.amber,
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
      'accent': AppTheme.success,
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
            _currentLocationText = 'Tap to enable location';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Fixed Top AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppTheme.cyanGradient,
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: Color(0xFF080B12),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ParkSync',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const Spacer(),

                // Theme Mode Switcher
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: appThemeMode,
                  builder: (context, mode, _) {
                    final isNight = mode == ThemeMode.dark;
                    return IconButton(
                      icon: Icon(
                        isNight ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                        color: isNight ? const Color(0xFFFFB800) : const Color(0xFF0284C7),
                      ),
                      onPressed: toggleThemeMode,
                    );
                  },
                ),

                // Language switcher
                IconButton(
                  icon: Icon(
                    Icons.language_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () => _showLanguageModal(context),
                ),

                const SizedBox(width: 4),

                // Profile Avatar Button
                InkWell(
                  onTap: () => setState(() => _navIndex = 3),
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: AppTheme.cyan.withValues(alpha: 0.15),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.cyan),
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
          _buildExploreView(context, isEn),
          _buildSavedView(context),
          _buildBookingsView(context),
          _buildProfileView(context),
        ],
      ),

      bottomNavigationBar: NavigationBar(
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
    );
  }

  Widget _buildExploreView(BuildContext context, bool isEn) {
    final spots = _filteredSpots;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto GPS / PIN code Banner
          InkWell(
            onTap: _fetchLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cyan.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  _isLocating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppTheme.cyan),
                          ),
                        )
                      : const Icon(Icons.my_location_rounded, size: 16, color: AppTheme.cyan),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _currentLocationText,
                      style: const TextStyle(
                        color: AppTheme.cyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Refresh GPS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Active Booking Card
          _ActiveBookingCard(
            onTap: () {
              context.push('/capture-evidence',
                  extra: {'bookingId': 'bk_live_01', 'type': 'BEFORE'});
            },
          ),

          const SizedBox(height: 20),

          // Interactive Search Bar (Typing works directly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.cyan, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where are you going?',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.map_rounded, color: AppTheme.cyan, size: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Covered'),
                _buildFilterChip('CCTV'),
                _buildFilterChip('Under ₹40'),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Vehicle Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_car_rounded,
                      color: AppTheme.cyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selected Vehicle', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(_vehicleDisplay,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/add-vehicle'),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nearby Spots Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Spots (${spots.length})',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () => context.push('/search', extra: ''),
                child: const Text('View on Map'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Spots List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: spots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final spot = spots[i];
              return _HomeSpotCard(
                spot: spot,
                onTap: () => context.push('/parking-detail', extra: spot['id']),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedFilter = label),
        selectedColor: AppTheme.cyan.withValues(alpha: isDark ? 0.2 : 0.25),
        checkmarkColor: isDark ? AppTheme.cyan : AppTheme.cyanLight,
        labelStyle: TextStyle(
          color: isSelected
              ? (isDark ? AppTheme.cyan : AppTheme.cyanLight)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSavedView(BuildContext context) {
    final savedList = _spots.where((s) => _savedSpotIds.contains(s['id'])).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Parking', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Your favorite parking bays for instant re-booking.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: savedList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final spot = savedList[i];
                return _HomeSpotCard(
                  spot: spot,
                  onTap: () => context.push('/parking-detail', extra: spot['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Reservations', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Live parking access codes and receipts.',
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

  Widget _buildProfileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.cyan.withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded, size: 32, color: AppTheme.cyan),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ParkSync Driver',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('+91 Verified Account • Gold Tier',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Preferences',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, _) {
              final isNight = mode == ThemeMode.dark;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: Icon(
                  isNight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isNight ? const Color(0xFFFFB800) : const Color(0xFF0284C7),
                ),
                title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(isNight ? 'Night Mode' : 'Bright Mode'),
                trailing: Switch(
                  value: isNight,
                  onChanged: (val) => toggleThemeMode(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.language_rounded, color: AppTheme.cyan),
            title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showLanguageModal(context),
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
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                title: const Text('English'),
                trailing: appLocale.value.languageCode == 'en'
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.cyan)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                title: const Text('मराठी (Marathi)'),
                trailing: appLocale.value.languageCode == 'mr'
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.cyan)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('mr');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                title: const Text('हिंदी (Hindi)'),
                trailing: appLocale.value.languageCode == 'hi'
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.cyan)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('hi');
                  Navigator.pop(context);
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00D4FF), Color(0xFF0088CC)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyan.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_parking_rounded, color: Colors.black, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ACTIVE SESSION',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bay A4 • Reserved',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to capture security evidence photo',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSpotCard extends StatelessWidget {
  final Map<String, dynamic> spot;
  final VoidCallback onTap;

  const _HomeSpotCard({required this.spot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color accent = spot['accent'] as Color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_parking_rounded, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot['name'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${spot['distance']} km away • ${spot['available']} spots open',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${spot['rate']}/hr',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Verified ✓',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
