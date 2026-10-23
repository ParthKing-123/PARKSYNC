import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class UserGuideScreen extends StatefulWidget {
  final int initialTab;
  const UserGuideScreen({super.key, this.initialTab = 0});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ParkSync Manual & Guide',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: () => context.pop(),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF23695B).withValues(alpha: 0.5) : AppTheme.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? (isDark ? AppTheme.forestElevated : AppTheme.butter)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _activeTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 16,
                                color: _activeTab == 0
                                    ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Seeker / Driver Guide',
                                style: TextStyle(
                                  fontWeight: _activeTab == 0 ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                  color: _activeTab == 0
                                      ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? (isDark ? AppTheme.forestElevated : AppTheme.butter)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _activeTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                size: 16,
                                color: _activeTab == 1
                                    ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Provider / Host Guide',
                                style: TextStyle(
                                  fontWeight: _activeTab == 1 ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                  color: _activeTab == 1
                                      ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: _activeTab == 0
                    ? _buildSeekerGuide(isDark)
                    : _buildProviderGuide(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SEEKER / DRIVER MANUAL ────────────────────────────────────────────────
  Widget _buildSeekerGuide(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          title: 'How Driver Parking Works',
          subtitle: 'Guaranteed reserved bays with automated dimensions & evidence verification.',
          icon: Icons.local_parking_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        _buildGuideStep(
          stepNumber: '1',
          title: 'Search by Landmark, City, or OpenStreetMap Pin',
          description:
              'Type your target destination or tap "Auto-detect my location". Explore available parking spots on the map with real-time bay availability counters.',
          icon: Icons.search_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '2',
          title: 'Smart Vehicle Dimensions Compatibility',
          description:
              'When you register your car or bike, ParkSync automatically validates height clearance, ramp angle, and bay length so your vehicle fits securely without scrapes.',
          icon: Icons.straighten_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '3',
          title: 'Choose Hours & Instant Booking',
          description:
              'Select reservation date and duration (from 1 hour to all day). Transparent hourly billing in ₹ with zero hidden convenience fees.',
          icon: Icons.calendar_today_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '4',
          title: 'Turn-by-Turn GPS Navigation',
          description:
              'Get direct routing to the exact entry gate, basement ramp, or driveway bay with phone and host emergency contact assistance.',
          icon: Icons.navigation_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '5',
          title: 'Capture Check-in & Check-out Evidence Photos',
          description:
              'Take a quick photo of your parked vehicle when arriving and leaving. Protects you against unauthorized damage disputes and records exact check-in timestamps.',
          icon: Icons.camera_alt_outlined,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '6',
          title: 'Hassle-Free Checkout & Rating',
          description:
              'Exit when done or extend your session with one tap. Rate your host and write reviews to keep our verified network trustworthy.',
          icon: Icons.star_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Quick action button
        NeumorphicButton(
          height: 48,
          onPressed: () => context.go('/guest-home'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_rounded, size: 18),
              SizedBox(width: 8),
              Text('Start Exploring Parking Now', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── PROVIDER / HOST MANUAL ────────────────────────────────────────────────
  Widget _buildProviderGuide(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          title: 'How Host Monetization Works',
          subtitle: 'Turn unused bays, driveways, or commercial decks into reliable recurring revenue.',
          icon: Icons.storefront_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        _buildGuideStep(
          stepNumber: '1',
          title: 'Select Facility Category & Enter Details',
          description:
              'Whether you are an individual driveway owner, café, hotel, or commercial parking lot operator, customize rules specifically for your bays.',
          icon: Icons.category_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '2',
          title: 'Platform Verification Machine',
          description:
              'Submit basic identity and facility ownership proof. Our automated status engine reviews submissions (DRAFT -> UNDER_REVIEW -> APPROVED) within 24 hours.',
          icon: Icons.verified_user_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '3',
          title: 'Set Rates & Operating Availability',
          description:
              'Choose your base rate (e.g. ₹40/hr) and open hours. Choose between Instant Bookings or manual driver request approvals with full control.',
          icon: Icons.currency_rupee_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '4',
          title: 'Manage Incoming Bookings in Real-Time',
          description:
              'Review incoming driver booking requests, inspect validated vehicle registration plates (RC), and approve or decline with one click.',
          icon: Icons.receipt_long_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '5',
          title: 'Instant Automated Wallet Payouts',
          description:
              'Payments are held securely in escrow and released directly to your host bank account or wallet as soon as the driver finishes their session.',
          icon: Icons.account_balance_wallet_rounded,
          isDark: isDark,
        ),

        _buildGuideStep(
          stepNumber: '6',
          title: 'Host Damage Protection Guarantee',
          description:
              'All drivers must submit verified vehicle registration details and check-in photos. Any facility damage is backed by our Host Protection Policy.',
          icon: Icons.shield_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Quick action button
        NeumorphicButton(
          height: 48,
          onPressed: () => context.push('/provider-onboarding'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_business_rounded, size: 18),
              SizedBox(width: 8),
              Text('Start Host Onboarding', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeroBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return NeumorphicCard(
      radius: 20,
      padding: const EdgeInsets.all(18),
      color: isDark ? null : AppTheme.butter,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: NeumorphicCard(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                ),
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
