import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../core/api_client.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/locale_provider.dart';
import '../../../core/theme_provider.dart';
import '../../../core/user_state_service.dart';
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
  final Set<String> _savedSpotIds = {};

  List<Map<String, dynamic>> _allListings = [];
  bool _isLoadingListings = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveListings();
  }

  Future<void> _fetchLiveListings() async {
    setState(() => _isLoadingListings = true);
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
            'name': map['title']?.toString() ?? 'ParkSync Space',
            'area': map['area']?.toString() ?? map['city']?.toString() ?? 'Central Hub',
            'city': map['city']?.toString() ?? '',
            'distance': '0.5',
            'rate': (map['pricePerHour'] as num?)?.round() ?? 40,
            'covered': map['covered'] == true,
            'cctv': map['cctv'] == true,
            'verified': true,
            'spots': availBays,
            'total': totalBays,
            'hostName': hostName,
            'color': AppTheme.forestGreen,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _allListings = list;
            _isLoadingListings = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('[GuestHomeScreen] Fetch spots error: $e');
    }
    if (mounted) {
      setState(() => _isLoadingListings = false);
    }
  }

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
                  color: Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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

                // Profile Avatar or Login Button
                ListenableBuilder(
                  listenable: UserStateService.instance,
                  builder: (context, _) {
                    final isLoggedIn = UserStateService.instance.isLoggedIn;
                    if (isLoggedIn) {
                      return InkWell(
                        onTap: () => setState(() => _navIndex = 3),
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(Icons.person_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                        ),
                      );
                    }
                    return NeumorphicButton(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => context.push('/login'),
                      child: const Text('Login'),
                    );
                  },
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
            color: isDark ? null : AppTheme.butter,
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                    decoration: InputDecoration(
                      hintText: isEn ? l!.searchPlaceholder : 'Search destination or area...',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFFA5C9C1) : AppTheme.textMutedLight,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
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
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
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
                  color: isDark ? null : AppTheme.butterElevated,
                  iconColor: isDark ? AppTheme.butter : AppTheme.forestGreen,
                  onTap: () => context.push('/search', extra: _searchCtrl.text),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Active Vehicle Selector / Fit Indicator ─────────────────────
          ListenableBuilder(
            listenable: UserStateService.instance,
            builder: (context, _) {
              final activeVehicle = UserStateService.instance.activeVehicle;
              if (activeVehicle != null) {
                return NeumorphicCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  radius: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.butter : AppTheme.forestGreen).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Vehicle Fit',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${activeVehicle.make} ${activeVehicle.model} • ${activeVehicle.plateNumber}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/add-vehicle'),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return NeumorphicCard(
                onTap: () => context.push('/add-vehicle'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                radius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.amber, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No Vehicle Selected',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          Text(
                            'Add vehicle to check height clearance & bay fit',
                            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              );
            },
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

          // Listings, Loading, or Empty State
          if (_isLoadingListings)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
              ),
            )
          else if (spots.isEmpty)
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

    final selectedBg = isDark ? AppTheme.butter : AppTheme.forestGreen;
    final selectedFg = isDark ? AppTheme.forestGreenDark : AppTheme.butter;
    final unselectedBg = isDark ? AppTheme.forestSurface : AppTheme.butterCream;
    final unselectedFg = isDark ? AppTheme.butter : AppTheme.forestGreen;
    final borderColor = isSelected
        ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
        : (isDark ? AppTheme.borderDark : AppTheme.borderLight);

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
        backgroundColor: unselectedBg,
        selectedColor: selectedBg,
        checkmarkColor: selectedFg,
        labelStyle: TextStyle(
          color: isSelected ? selectedFg : unselectedFg,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildSpotCard(BuildContext context, Map<String, dynamic> spot, bool isSaved) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF23695B).withValues(alpha: 0.6) : AppTheme.borderLight,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.local_parking_rounded,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot['name'],
                      style: TextStyle(
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${spot['distance']} km away • ${spot['area']}',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Bookmark button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                      : (isDark ? const Color(0xFFA5C9C1) : AppTheme.textMutedLight),
                  size: 22,
                ),
                onPressed: () => _toggleSaveSpot(spot['id']),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (spot['covered'] == true) _buildMiniTag('Covered', isDark),
                  if (spot['cctv'] == true) ...[
                    const SizedBox(width: 6),
                    _buildMiniTag('CCTV', isDark),
                  ],
                  if (spot['verified'] == true) ...[
                    const SizedBox(width: 6),
                    _buildMiniTag('Verified ✓', isDark, isVerified: true),
                  ],
                ],
              ),
              RichText(
                text: TextSpan(
                  text: '₹${spot['rate']}',
                  style: TextStyle(
                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: '/hr',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textMutedLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _buildMiniTag(String text, bool isDark, {bool isVerified = false}) {
    final bg = isVerified
        ? (isDark ? const Color(0xFF0F4335) : const Color(0xFFD3EFE5))
        : (isDark ? const Color(0xFF143B33) : const Color(0xFFFEEDBA));
    final fg = isVerified
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF045842))
        : (isDark ? AppTheme.butter : AppTheme.forestGreen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDark
              ? const Color(0xFF23695B).withValues(alpha: 0.5)
              : const Color(0xFFE2C988).withValues(alpha: 0.8),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
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
                  onPressed: () => context.push('/user-guide'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Explore Driver Guide', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF014B43), Color(0xFF002722)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppTheme.butter.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.75)
                      : AppTheme.forestGreen.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.butter.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.butter.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: AppTheme.butter),
                          SizedBox(width: 6),
                          Text(
                            'ACTIVE SESSION',
                            style: TextStyle(
                              color: AppTheme.butter,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Bay A4',
                      style: TextStyle(
                        color: AppTheme.butter,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Metro Grand Parking Bay',
                  style: TextStyle(
                    color: AppTheme.butter,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid Today • 10:00 AM - 12:00 PM (2 hrs)',
                  style: TextStyle(
                    color: AppTheme.butter.withValues(alpha: 0.85),
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
                        label: const Text('Capture Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.butter,
                          foregroundColor: AppTheme.forestGreenDark,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        label: const Text('Navigate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.butter,
                          side: const BorderSide(color: AppTheme.butter, width: 1.5),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.success.withValues(alpha: isDark ? 0.45 : 0.25),
              ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ref,
                style: TextStyle(
                  color: isDark ? const Color(0xFFA5C9C1) : AppTheme.textMutedLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
    return ListenableBuilder(
      listenable: UserStateService.instance,
      builder: (context, _) {
        final isLoggedIn = UserStateService.instance.isLoggedIn;
        final userName = UserStateService.instance.userName;
        final phone = UserStateService.instance.phoneNumber;
        final vehiclesCount = UserStateService.instance.vehicles.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                radius: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.15),
                      child: Icon(
                        isLoggedIn ? Icons.verified_user_rounded : Icons.person_rounded,
                        size: 34,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? userName : 'Guest User',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isLoggedIn
                                ? (phone.isNotEmpty ? phone : 'Verified Account')
                                : 'Login to sync vehicles & bookings',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.forestGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PARKING SEEKER • $vehiclesCount VEHICLE(S)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isLoggedIn)
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
                      color: isNight ? AppTheme.accentGold : AppTheme.forestGreen,
                    ),
                    title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(isNight ? 'Night Mode (Active)' : 'Bright Mode (Active)'),
                    trailing: Switch(
                      value: isNight,
                      activeThumbColor: AppTheme.accentGold,
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
                leading: Icon(Icons.language_rounded, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
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
                leading: Icon(Icons.directions_car_rounded, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
                title: const Text('My Vehicles', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  vehiclesCount > 0 ? '$vehiclesCount vehicle(s) saved' : 'Register vehicle dimensions for bay fitting',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => context.push('/add-vehicle'),
              ),

              const SizedBox(height: 24),

              Text(
                'Help & Legal',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Driver Guide Manual Tile
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: const Icon(Icons.menu_book_rounded, color: AppTheme.forestGreen),
                title: const Text('ParkSync User Guide & Manual', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Driver & host walkthrough, search, & reservations'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => context.push('/user-guide', extra: 0),
              ),

              const SizedBox(height: 10),

              // Privacy Policy Tile
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: const Icon(Icons.policy_rounded, color: AppTheme.forestGreen),
                title: const Text('Privacy Policy & Terms of Service', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('DPDP Act 2023 compliance & reservation terms'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => context.push('/privacy-policy', extra: 0),
              ),


              if (isLoggedIn) ...[
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.error),
                  ),
                  subtitle: const Text('Sign out of your ParkSync seeker account'),
                  onTap: () async {
                    await UserStateService.instance.logout();
                    if (context.mounted) {
                      SweetPopup.show(
                        context,
                        title: 'Logged Out',
                        message: 'You have been safely signed out.',
                        icon: Icons.check_circle_rounded,
                      );
                    }
                  },
                ),
              ],

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
      },
    );
  }

  void _showLanguageModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    ? Icon(Icons.check_circle_rounded, color: isDark ? AppTheme.butter : AppTheme.forestGreen)
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
                    ? Icon(Icons.check_circle_rounded, color: isDark ? AppTheme.butter : AppTheme.forestGreen)
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
                    ? Icon(Icons.check_circle_rounded, color: isDark ? AppTheme.butter : AppTheme.forestGreen)
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
