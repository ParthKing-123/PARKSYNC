import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/locale_provider.dart';

/// Guest-facing home — shows parking listings immediately.
/// No login required to browse. Login is prompted only when booking.
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  int _navIndex = 0;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Mock data ──────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _mockListings = [
    {
      'id': 'p1',
      'name': 'Metro Grand Parking Bay',
      'distance': '0.3',
      'rate': '60',
      'covered': true,
      'cctv': true,
      'verified': true,
      'spots': 4,
      'color': const Color(0xFF00D4FF),
    },
    {
      'id': 'p2',
      'name': 'Central Commercial Plaza',
      'distance': '1.2',
      'rate': '40',
      'covered': true,
      'cctv': true,
      'verified': false,
      'spots': 12,
      'color': const Color(0xFF7C3AED),
    },
    {
      'id': 'p3',
      'name': 'Tech Hub Multi-Level Lot',
      'distance': '2.4',
      'rate': '30',
      'covered': false,
      'cctv': false,
      'verified': true,
      'spots': 7,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'p4',
      'name': 'Station Road Secure Bay',
      'distance': '3.1',
      'rate': '20',
      'covered': false,
      'cctv': true,
      'verified': true,
      'spots': 20,
      'color': const Color(0xFFFFB800),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Subtle animated gradient bg ───────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              final t = _bgController.value * 2 * pi;
              return Stack(children: [
                Positioned(
                  left: size.width * 0.5 + cos(t * 0.4) * 80,
                  top: -100 + sin(t * 0.4) * 40,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppTheme.cyan.withOpacity(0.08),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  right: -50 + cos(t * 0.3 + 1.2) * 60,
                  bottom: size.height * 0.4 + sin(t * 0.3 + 1.2) * 40,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppTheme.violet.withOpacity(0.1),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ]);
            },
          ),

          // ── Main scroll content ───────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
                toolbarHeight: 64,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Logo
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: AppTheme.cyanGradient,
                          ),
                          child: const Icon(
                            Icons.local_parking_rounded,
                            color: AppTheme.bgBase,
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
                        // Language switcher
                        _LanguagePill(),
                        const SizedBox(width: 10),
                        // Login CTA
                        GestureDetector(
                          onTap: () => context.push('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.cyan.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: AppTheme.cyan),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero heading ───────────────────────────────
                      const SizedBox(height: 16),
                      Text(
                        l.findParkingNear,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thousands of verified spots across India.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // ── Search bar ─────────────────────────────────
                      _SearchBar(
                        controller: _searchCtrl,
                        hint: l.searchPlaceholder,
                        onTap: () => context.push('/search', extra: _searchCtrl.text),
                      ),

                      const SizedBox(height: 32),

                      // ── Quick filter chips ─────────────────────────
                      _QuickFilters(),

                      const SizedBox(height: 28),

                      // ── Nearby spots heading ───────────────────────
                      Row(
                        children: [
                          Text(
                            l.nearbySpots,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/search', extra: ''),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Parking listings ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: _mockListings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final spot = _mockListings[i];
                    return _ParkingCard(
                      spot: spot,
                      onTap: () => _onSpotTapped(context, spot['id']),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── "How it works" section ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HowItWorksSection(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),

      // ── Bottom Nav ─────────────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: l.explore,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline_rounded),
            selectedIcon: const Icon(Icons.bookmark_rounded),
            label: l.saved,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l.bookings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l.profile,
          ),
        ],
      ),
    );
  }

  void _onSpotTapped(BuildContext context, String id) {
    // Guests can VIEW details — login prompted inside detail screen at booking
    context.push('/parking-detail', extra: id);
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _SearchBar({required this.controller, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C2A42)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyan.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.cyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textMuted),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.my_location_rounded,
                  color: AppTheme.cyan, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilters extends StatefulWidget {
  @override
  State<_QuickFilters> createState() => _QuickFiltersState();
}

class _QuickFiltersState extends State<_QuickFilters> {
  int _selected = 0;
  final List<String> _filters = ['All', 'Covered', 'CCTV', 'Verified', 'Open Now'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.cyan.withOpacity(0.15)
                    : AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppTheme.cyan.withOpacity(0.5)
                      : const Color(0xFF1C2A42),
                ),
              ),
              child: Text(
                _filters[i],
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? AppTheme.cyan : AppTheme.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParkingCard extends StatelessWidget {
  final Map<String, dynamic> spot;
  final VoidCallback onTap;

  const _ParkingCard({required this.spot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = spot['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1C2A42)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_parking_rounded,
                      color: accentColor, size: 22),
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
                      const SizedBox(height: 2),
                      Text(
                        '${spot['distance']} km away • ${spot['spots']} spots left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                // Rate
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${spot['rate']}/hr',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'onwards',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: Color(0xFF1C2A42)),
            const SizedBox(height: 12),
            // Feature badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (spot['covered'] == true)
                  _Badge(label: 'Covered', color: AppTheme.cyan),
                if (spot['cctv'] == true)
                  _Badge(label: 'CCTV', color: AppTheme.violet),
                if (spot['verified'] == true)
                  _Badge(label: '✓ Verified', color: AppTheme.success),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider
        Container(height: 1, color: const Color(0xFF1C2A42)),
        const SizedBox(height: 32),

        Text(
          'How it works',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Two ways to use ParkSync.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // Driver card
        _RoleInfoCard(
          icon: Icons.directions_car_rounded,
          iconColor: AppTheme.cyan,
          title: 'For Drivers',
          description:
              'Browse thousands of verified parking spots across India. Book in seconds, park stress-free. Pay only for the time you use.',
          ctaLabel: 'Explore Parking',
          ctaColor: AppTheme.cyan,
          onTap: () {},
        ),

        const SizedBox(height: 16),

        // Provider card
        _RoleInfoCard(
          icon: Icons.storefront_rounded,
          iconColor: AppTheme.violet,
          title: 'For Providers',
          description:
              'Have an empty driveway or parking bay? List it on ParkSync and earn every hour it\'s used. Zero upfront cost.',
          ctaLabel: 'List Your Space',
          ctaColor: AppTheme.violet,
          onTap: () => context.push('/provider-onboarding'),
        ),
      ],
    );
  }
}

class _RoleInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String ctaLabel;
  final Color ctaColor;
  final VoidCallback onTap;

  const _RoleInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.ctaColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1C2A42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ctaColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ctaColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctaLabel,
                    style: TextStyle(
                      color: ctaColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: ctaColor, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language pill widget ───────────────────────────────────────────────────

class _LanguagePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguageSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1C2A42)),
        ),
        child: const Icon(Icons.language_rounded,
            color: AppTheme.textSecondary, size: 18),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _LanguageSheet(),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final langs = [
      ('English', const Locale('en'), '🇬🇧'),
      (l.marathi, const Locale('mr'), '🇮🇳'),
      (l.hindi, const Locale('hi'), '🇮🇳'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.language, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          ...langs.map((lang) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(lang.$3, style: const TextStyle(fontSize: 24)),
              title: Text(lang.$1,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600)),
              trailing: ValueListenableBuilder<Locale>(
                valueListenable: appLocale,
                builder: (_, current, __) {
                  return current == lang.$2
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.cyan)
                      : const SizedBox.shrink();
                },
              ),
              onTap: () {
                appLocale.value = lang.$2;
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
