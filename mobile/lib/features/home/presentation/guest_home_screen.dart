import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/locale_provider.dart';
import '../../../core/theme_provider.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

/// Main Guest & Marketplace Screen
/// - Fixed top AppBar (stays at top within screen metrics, never scrolls down)
/// - Light / Dark mode toggle button
/// - Functional 4 bottom tabs: Explore, Saved, Bookings, Profile
/// - Interactive destination search with real typing and live filtering
/// - Working filter chips (All, Covered, CCTV, Verified, Under ₹40)
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  int _navIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';
  final Set<String> _savedSpotIds = {'p1'}; // Default one spot saved for demo

  // Master listing data (Pan-India)
  final List<Map<String, dynamic>> _allListings = [
    {
      'id': 'p1',
      'name': 'Metro Grand Parking Bay',
      'area': 'Station Central Hub',
      'distance': '0.3',
      'rate': 50,
      'covered': true,
      'cctv': true,
      'verified': true,
      'spots': 4,
      'color': AppTheme.forestGreen,
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
      'spots': 12,
      'color': const Color(0xFF7C3AED),
    },
    {
      'id': 'p3',
      'name': 'Tech Hub Multi-Level Lot',
      'area': 'Cyber Park Avenue',
      'distance': '2.4',
      'rate': 30,
      'covered': false,
      'cctv': true,
      'verified': true,
      'spots': 7,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'p4',
      'name': 'Station Road Secure Bay',
      'area': 'Terminal North Gate',
      'distance': '3.1',
      'rate': 25,
      'covered': true,
      'cctv': false,
      'verified': false,
      'spots': 20,
      'color': const Color(0xFFFFB800),
    },
    {
      'id': 'p5',
      'name': 'National Mall Basement Lot',
      'area': 'City Center Mall',
      'distance': '1.8',
      'rate': 35,
      'covered': true,
      'cctv': true,
      'verified': true,
      'spots': 15,
      'color': AppTheme.forestGreen,
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Get dynamically filtered spots
  List<Map<String, dynamic>> get _filteredSpots {
    final query = _searchCtrl.text.toLowerCase().trim();

    return _allListings.where((spot) {
      // 1. Text search filter
      if (query.isNotEmpty) {
        final name = spot['name'].toString().toLowerCase();
        final area = spot['area'].toString().toLowerCase();
        if (!name.contains(query) && !area.contains(query)) {
          return false;
        }
      }

      // 2. Chip filter
      if (_selectedFilter == 'Covered' && spot['covered'] != true) return false;
      if (_selectedFilter == 'CCTV' && spot['cctv'] != true) return false;
      if (_selectedFilter == 'Verified' && spot['verified'] != true) return false;
      if (_selectedFilter == 'Under ₹40' && (spot['rate'] as int) > 40) return false;

      return true;
    }).toList();
  }

  void _toggleSaveSpot(String id) {
    setState(() {
      if (_savedSpotIds.contains(id)) {
        _savedSpotIds.remove(id);
        SweetPopup.show(
          context,
          title: 'Removed from Favorites',
          message: 'Parking bay removed from your saved list.',
          icon: Icons.bookmark_remove_rounded,
          iconColor: Colors.grey,
        );
      } else {
        _savedSpotIds.add(id);
        SweetPopup.show(
          context,
          title: 'Saved to Favorites!',
          message: 'Parking bay saved for instant re-booking.',
          icon: Icons.bookmark_added_rounded,
          iconColor: AppTheme.amber,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ── Fixed Top AppBar: Stays at the top within safe phone metrics ────
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
                // ParkSync Logo badge
                NeumorphicIconBadge(
                  icon: Icons.local_parking_rounded,
                  size: 38,
                  iconSize: 22,
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

                // Theme Mode Switcher (Dark / Light)
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

                // Language switcher pill
                NeumorphicIconBadge(
                  icon: Icons.language_rounded,
                  size: 38,
                  iconSize: 19,
                  onTap: () => _showLanguageModal(context),
                ),

                const SizedBox(width: 8),

                // Login Button
                NeumorphicButton(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () => context.push('/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── Functional Body: Switches between the 4 Bottom Tabs ──────────
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildExploreView(context, isEn, isDark),
          _buildSavedView(context, isEn, isDark),
          _buildBookingsView(context, isEn, isDark),
          _buildProfileView(context, isEn, isDark),
        ],
      ),

      // ── Functional Bottom Navigation Bar ──────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          setState(() => _navIndex = index);
        },
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

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0: EXPLORE VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExploreView(BuildContext context, bool isEn, bool isDark) {
    final l = AppLocalizations.of(context);
    final spots = _filteredSpots;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline
          Text(
            isEn ? l!.findParkingNear : 'Find parking\nnear you.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Verified parking bays across India with guaranteed spots.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),

          // ── Real Interactive Search Bar (Typing works directly) ────────
          NeumorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            radius: 16,
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.forestGreen, size: 22),
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
                      hintText: isEn ? l!.searchPlaceholder : 'Search destination or area...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {}); // Live filter spots
                    },
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    color: Theme.of(context).colorScheme.outline,
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  ),
                // Open Map Button
                NeumorphicIconBadge(
                  icon: Icons.map_rounded,
                  size: 36,
                  iconSize: 18,
                  iconColor: AppTheme.forestGreen,
                  onTap: () => context.push('/search', extra: _searchCtrl.text),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Working Filter Chips ───────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Covered'),
                _buildFilterChip('CCTV'),
                _buildFilterChip('Verified'),
                _buildFilterChip('Under ₹40'),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Header count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Spots (${spots.length})',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
              if (_selectedFilter != 'All' || _searchCtrl.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _selectedFilter = 'All');
                  },
                  child: const Text('Reset filters'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Listings or Empty State
          if (spots.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No spots match your search or filter.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _selectedFilter = 'All');
                    },
                    child: const Text('Clear Search & Show All'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final spot = spots[i];
                final isSaved = _savedSpotIds.contains(spot['id']);
                return _buildSpotCard(context, spot, isSaved);
              },
            ),

          const SizedBox(height: 28),

          // Informational "How It Works" Section
          _buildHowItWorksCard(context),

          const SizedBox(height: 20),
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
        onSelected: (val) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppTheme.cyan.withValues(alpha: isDark ? 0.2 : 0.25),
        checkmarkColor: isDark ? AppTheme.cyan : AppTheme.cyanLight,
        labelStyle: TextStyle(
          color: isSelected
              ? (isDark ? AppTheme.cyan : AppTheme.cyanLight)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppTheme.cyan
                : (Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42)),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotCard(BuildContext context, Map<String, dynamic> spot, bool isSaved) {
    final Color accent = spot['color'] as Color;

    return NeumorphicCard(
      onTap: () => context.push('/parking-detail', extra: spot['id']),
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        '${spot['distance']} km away • ${spot['area']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                // Bookmark button
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? AppTheme.cyan : Theme.of(context).colorScheme.outline,
                    size: 22,
                  ),
                  onPressed: () => _toggleSaveSpot(spot['id']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (spot['covered'] == true) _buildMiniTag('Covered', AppTheme.cyan),
                    if (spot['cctv'] == true) ...[
                      const SizedBox(width: 6),
                      _buildMiniTag('CCTV', AppTheme.violet),
                    ],
                    if (spot['verified'] == true) ...[
                      const SizedBox(width: 6),
                      _buildMiniTag('Verified ✓', AppTheme.success),
                    ],
                  ],
                ),
                RichText(
                  text: TextSpan(
                    text: '₹${spot['rate']}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: '/hr',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'How ParkSync Works',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'ParkSync enables drivers to pre-book verified parking slots in seconds, while empowering hosts to monetize unused space across India.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  height: 42,
                  onPressed: () => context.push('/role-selection'),
                  child: const Text('Read Guide', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeumorphicButton(
                  height: 42,
                  onPressed: () => context.push('/provider-onboarding'),
                  child: const Text('List Space', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: SAVED VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSavedView(BuildContext context, bool isEn, bool isDark) {
    final savedList = _allListings.where((s) => _savedSpotIds.contains(s['id'])).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Parking', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Your bookmarked parking spots for quick access.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (savedList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved spots yet',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap the bookmark icon on any parking spot to save it.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => _navIndex = 0),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                      child: const Text('Explore Spots'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: savedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return _buildSpotCard(context, savedList[i], true);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: BOOKINGS VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBookingsView(BuildContext context, bool isEn, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Bookings', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Active reservations and past parking history.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Active Booking Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.forestGreen, AppTheme.forestGreenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.black),
                          SizedBox(width: 6),
                          Text(
                            'ACTIVE SESSION',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Bay A4',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Metro Grand Parking Bay',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid Today • 10:00 AM - 12:00 PM (2 hrs)',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Capture Photo', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                        ),
                        onPressed: () {
                          context.push(
                            '/capture-evidence',
                            extra: {'bookingId': 'bk_live_01', 'type': 'BEFORE'},
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.navigation_outlined, size: 16),
                        label: const Text('Navigate', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        onPressed: () {
                          context.push('/search', extra: 'Metro Grand Parking Bay');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Past Completed Bookings',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),

          _buildPastBookingCard(
            context,
            name: 'Central Commercial Plaza',
            date: 'Yesterday, 02:30 PM - 04:30 PM',
            rate: '₹80.00',
            ref: 'PS-8921',
          ),
          const SizedBox(height: 10),
          _buildPastBookingCard(
            context,
            name: 'Station Road Secure Bay',
            date: '12 Oct 2026, 09:00 AM - 11:00 AM',
            rate: '₹50.00',
            ref: 'PS-7740',
          ),
        ],
      ),
    );
  }

  Widget _buildPastBookingCard(
    BuildContext context, {
    required String name,
    required String date,
    required String rate,
    required String ref,
  }) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
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
                rate,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                ref,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: PROFILE VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileView(BuildContext context, bool isEn, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Card
          NeumorphicCard(
            padding: const EdgeInsets.all(20),
            radius: 20,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.forestGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Guest User',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login to sync vehicles & bookings',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                NeumorphicButton(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () => context.push('/login'),
                  child: const Text('Login', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Settings & Preferences',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Theme Mode Switch Tile
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
                subtitle: Text(isNight ? 'Night Mode (Active)' : 'Bright Mode (Active)'),
                trailing: Switch(
                  value: isNight,
                  onChanged: (val) => toggleThemeMode(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Language Tile
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.language_rounded, color: AppTheme.cyan),
            title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              appLocale.value.languageCode == 'mr'
                  ? 'मराठी (Marathi)'
                  : (appLocale.value.languageCode == 'hi' ? 'हिंदी (Hindi)' : 'English'),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showLanguageModal(context),
          ),

          const SizedBox(height: 10),

          // My Vehicles Tile
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.directions_car_rounded, color: AppTheme.violet),
            title: const Text('My Vehicles', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Register vehicle dimensions for bay fitting'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => context.push('/add-vehicle'),
          ),

          const SizedBox(height: 24),

          Text(
            'Partner with ParkSync',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Host Onboarding Tile
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.storefront_rounded, color: AppTheme.success),
            title: const Text('Become a Parking Host', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('List driveways, lots, or commercial bays'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => context.push('/provider-onboarding'),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'ParkSync India • v1.0.0 (Enterprise Build)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
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
