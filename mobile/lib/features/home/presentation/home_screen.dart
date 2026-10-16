import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../core/locale_provider.dart';
import '../../../shared/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocationText = 'Detecting location...';
  bool _isLocating = false;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
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
          _currentLocationText = 'Near Your Location';
          _isLocating = false;
        });
      }
    }
  }

  // Generic national listings (India-wide)
  static final List<Map<String, dynamic>> _spots = [
    {
      'id': 'p1',
      'name': 'Metro Grand Parking Bay',
      'distance': '0.3',
      'rate': '50',
      'covered': true,
      'cctv': true,
      'verified': true,
      'available': 4,
      'accent': AppTheme.cyan,
    },
    {
      'id': 'p2',
      'name': 'Central Commercial Plaza',
      'distance': '1.1',
      'rate': '40',
      'covered': true,
      'cctv': true,
      'verified': true,
      'available': 12,
      'accent': AppTheme.violet,
    },
    {
      'id': 'p3',
      'name': 'Tech Hub Multi-Level Lot',
      'distance': '2.0',
      'rate': '30',
      'covered': false,
      'cctv': true,
      'verified': true,
      'available': 8,
      'accent': AppTheme.amber,
    },
    {
      'id': 'p4',
      'name': 'Station Road Secure Bay',
      'distance': '3.2',
      'rate': '25',
      'covered': true,
      'cctv': false,
      'verified': true,
      'available': 18,
      'accent': AppTheme.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: AppTheme.cyanGradient,
              ),
              child: const Icon(
                Icons.local_parking_rounded,
                color: AppTheme.bgBase,
                size: 18,
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
          ],
        ),
        actions: [
          // Language switcher
          IconButton(
            icon: const Icon(Icons.language_rounded, size: 20),
            color: AppTheme.textSecondary,
            onPressed: () => _showLanguageModal(context),
          ),
          // User avatar
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.bgElevated,
              child: const Icon(Icons.person_rounded,
                  size: 18, color: AppTheme.cyan),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1829),
              AppTheme.bgBase,
            ],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Auto GPS / PIN code Banner ──────────────────────────────
                InkWell(
                  onTap: _fetchLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.cyan.withValues(alpha: 0.2)),
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
                            : const Icon(Icons.my_location_rounded,
                                size: 16, color: AppTheme.cyan),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentLocationText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.cyan,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Refresh GPS',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Active Booking Card (Dynamic Island / Assistant Card) ──
                _ActiveBookingCard(
                  onTap: () {
                    context.push('/capture-evidence',
                        extra: {'bookingId': 'bk_live_01', 'type': 'BEFORE'});
                  },
                ),

                const SizedBox(height: 24),

                // ── Hero Title ───────────────────────────────────────────────
                Text(
                  isEn ? l.findParkingNear : 'Find parking\nnear you.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 20),

                // ── Search Input ─────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.push('/search', extra: _currentLocationText),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgInput,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1C2A42)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cyan.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppTheme.cyan, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEn ? l.searchDestination : 'Where are you going?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppTheme.cyan, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Vehicle Selector Pill ────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1C2A42)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.directions_car_rounded,
                            color: AppTheme.cyan, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? l.selectedVehicle : 'Selected Vehicle',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Standard Passenger Vehicle',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/add-vehicle'),
                        child: Text(isEn ? l.changeVehicle : 'Change'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Nearby Spots Header ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? l.nearbySpots : 'Nearby spots',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 20,
                              ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/search', extra: ''),
                      child: const Text('View Map'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Spot Cards List ──────────────────────────────────────────
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _spots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final spot = _spots[i];
                    return _HomeSpotCard(
                      spot: spot,
                      onTap: () =>
                          context.push('/parking-detail', extra: spot['id']),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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

  void _showLanguageModal(BuildContext context) {
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Language / भाषा निवडा',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                title: const Text('English'),
                trailing: appLocale.value.languageCode == 'en'
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.cyan)
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
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.cyan)
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
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.cyan)
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
            colors: [
              Color(0xFF00D4FF),
              Color(0xFF0088CC),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyan.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
              child: const Icon(
                Icons.local_parking_rounded,
                color: Colors.black,
                size: 26,
              ),
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
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 14,
              ),
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
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C2A42)),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
