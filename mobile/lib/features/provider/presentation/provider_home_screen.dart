import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';
import '../../../core/user_state_service.dart';
import './provider_bookings_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _ProviderDashboardView(),
    const _ProviderListingsView(),
    const ProviderBookingsScreen(),
    const _ProviderProfileSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking_rounded),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 0: PROVIDER DASHBOARD VIEW
// ════════════════════════════════════════════════════════════════════════════
class _ProviderDashboardView extends StatelessWidget {
  const _ProviderDashboardView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: UserStateService.instance,
      builder: (context, _) {
        final facility = UserStateService.instance.providerFacility;
        final hasFacility = facility != null;
        final status = facility?.verificationStatus ?? VerificationStatus.draft;
        final isApproved = status == VerificationStatus.approved;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Host Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Center(
                  child: NeumorphicIconBadge(
                    icon: Icons.menu_book_rounded,
                    size: 38,
                    iconSize: 18,
                    onTap: () => context.push('/user-guide', extra: 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Center(
                  child: NeumorphicIconBadge(
                    icon: Icons.swap_horiz_rounded,
                    size: 38,
                    iconSize: 18,
                    onTap: () async {
                      await UserStateService.instance.switchRole(UserRole.seeker);
                      if (context.mounted) {
                        SweetPopup.show(
                          context,
                          title: 'Switched to Driver Mode',
                          message: 'Now browsing parking spaces as a driver.',
                          icon: Icons.directions_car_rounded,
                        );
                        context.go('/home');
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Dynamic Verification Status Alert Banner ───────────────
                NeumorphicCard(
                  padding: const EdgeInsets.all(18),
                  radius: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (!hasFacility
                                  ? AppTheme.accentGold
                                  : (isApproved ? AppTheme.success : AppTheme.amber))
                              .withValues(alpha: isDark ? 0.25 : 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          !hasFacility
                              ? Icons.add_location_alt_rounded
                              : (isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded),
                          color: !hasFacility
                              ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                              : (isApproved ? AppTheme.success : AppTheme.amber),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  !hasFacility
                                      ? 'Facility Setup Pending'
                                      : (isApproved ? 'Listing Active & Live' : 'Verification Under Review'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (!hasFacility
                                            ? AppTheme.accentGold
                                            : (isApproved ? AppTheme.success : AppTheme.amber))
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    !hasFacility ? 'SETUP REQUIRED' : status.code,
                                    style: TextStyle(
                                      color: !hasFacility
                                          ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                          : (isApproved ? AppTheme.success : AppTheme.amber),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              !hasFacility
                                  ? 'You have not listed any parking space yet. Complete the onboarding steps to start earning.'
                                  : (isApproved
                                      ? 'Your facility is verified. Drivers can discover and reserve bays in real time.'
                                      : 'ParkSync Trust & Safety team is validating your facility coordinates and authorization. Unapproved listings cannot receive public bookings yet.'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Earnings Summary (Distinguishing Real vs Mock) ─────────
                NeumorphicCard(
                  padding: const EdgeInsets.all(22),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Real Wallet Balance', style: Theme.of(context).textTheme.bodyMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LIVE ACCOUNT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹0.00',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                              fontSize: 36,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Real payouts will appear here upon completion of verified parking sessions.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(height: 24),
                      // Projected demo analytics (clearly marked)
                      Row(
                        children: [
                          Icon(Icons.query_stats_rounded, size: 16, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo Projection: ₹3,420 estimated monthly revenue at 80% occupancy.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Quick Metric Pills ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicCard(
                        padding: const EdgeInsets.all(16),
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Bays', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '${facility?.totalBays ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicCard(
                        padding: const EdgeInsets.all(16),
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Bays', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '${facility?.availableBays ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.success),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicCard(
                        padding: const EdgeInsets.all(16),
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hourly Rate', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '₹${facility?.hourlyRate.toInt() ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Primary Facility Preview Card ─────────────────────────
                Text(
                  'Primary Facility',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),

                if (facility == null)
                  NeumorphicCard(
                    radius: 18,
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      children: [
                        const Icon(Icons.add_business_rounded, color: AppTheme.amber, size: 38),
                        const SizedBox(height: 10),
                        const Text(
                          'No Active Facility Registered',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You have not added your parking bays yet. Complete the onboarding to start monetizing space.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        NeumorphicButton(
                          height: 42,
                          onPressed: () => context.push('/provider-onboarding'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Add Parking Facility', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  NeumorphicCard(
                    radius: 18,
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.forestGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.local_parking_rounded, color: AppTheme.forestGreen, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facility.facilityName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    facility.address,
                                    style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildChip(context, '${facility.slotType} Slot'),
                            _buildChip(context, facility.operatingHours),
                            _buildChip(context, '₹${facility.hourlyRate.toInt()}/hr'),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Quick Guide & Help CTA ─────────────────────────────────
                NeumorphicCard(
                  onTap: () => context.push('/user-guide', extra: 1),
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  child: const Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: AppTheme.forestGreen, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Host Operating Manual', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('Read SOP for check-ins, security & payouts', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1: PROVIDER LISTINGS VIEW
// ════════════════════════════════════════════════════════════════════════════
class _ProviderListingsView extends StatelessWidget {
  const _ProviderListingsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: UserStateService.instance,
      builder: (context, _) {
        final facility = UserStateService.instance.providerFacility;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Your Parking Facilities',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => context.push('/provider-onboarding'),
                tooltip: 'Add Facility',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (facility == null) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.local_parking_rounded, size: 54, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          const Text(
                            'No facilities registered yet',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.push('/provider-onboarding'),
                            child: const Text('Complete Provider Onboarding'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  NeumorphicCard(
                    padding: const EdgeInsets.all(20),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.forestGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                facility.category,
                                style: const TextStyle(
                                  color: AppTheme.forestGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (facility.verificationStatus == VerificationStatus.approved
                                        ? AppTheme.success
                                        : AppTheme.amber)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                facility.verificationStatus.code,
                                style: TextStyle(
                                  color: facility.verificationStatus == VerificationStatus.approved
                                      ? AppTheme.success
                                      : AppTheme.amber,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (facility.verificationStatus != VerificationStatus.approved) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => context.push('/super-admin'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.amber.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.hourglass_top_rounded, size: 18, color: AppTheme.amber),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Listing Under Review',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.amber),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Pending platform developer verification. Tap to review in Super Admin Console.',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.amber,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Review',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          facility.facilityName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility.businessName,
                          style: TextStyle(
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${facility.address}, ${facility.city} - ${facility.pincode}',
                                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed_rounded, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'GPS: ${facility.latitude.toStringAsFixed(4)}°N, ${facility.longitude.toStringAsFixed(4)}°E',
                              style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildFacilityInfoRow('Total Bays', '${facility.totalBays} Bays (${facility.availableBays} Available)'),
                        _buildFacilityInfoRow('Slot Type & Clearance', '${facility.slotType} • ${facility.heightClearance}'),
                        _buildFacilityInfoRow('Hourly Rate', '₹${facility.hourlyRate.toInt()}/hr'),
                        _buildFacilityInfoRow('Operating Hours', '${facility.operatingHours} (${facility.operatingDays})'),
                        const SizedBox(height: 12),
                        const Text('Allowed Vehicles:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: facility.allowedVehicles
                              .map((v) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(v, style: const TextStyle(fontSize: 11)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text('Facility Amenities:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: facility.amenities
                              .map((a) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(a, style: const TextStyle(fontSize: 11)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  NeumorphicButton(
                    onPressed: () => context.push('/provider-onboarding'),
                    child: const Text('+ Add Additional Parking Bay / Facility'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacilityInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 3: PROVIDER PROFILE & SETTINGS VIEW
// ════════════════════════════════════════════════════════════════════════════
class _ProviderProfileSettingsView extends StatelessWidget {
  const _ProviderProfileSettingsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: UserStateService.instance,
      builder: (context, _) {
        final facility = UserStateService.instance.providerFacility;
        final name = facility?.contactPerson ?? 'Registered Host';
        final phone = facility?.contactPhone ?? UserStateService.instance.phoneNumber;
        final biz = facility?.businessName ?? 'ParkSync Parking Host';

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Host Settings & Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                NeumorphicCard(
                  padding: const EdgeInsets.all(20),
                  radius: 20,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.15),
                        child: const Icon(Icons.storefront_rounded, size: 34, color: AppTheme.forestGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              biz,
                              style: TextStyle(
                                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Host Operating Guidelines',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),

                // Host User Guide Tile
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.menu_book_rounded, color: AppTheme.forestGreen),
                  title: const Text('Host User Guide & Manual', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Operating SOP, booking confirmations, & safety checks'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/user-guide', extra: 1),
                ),

                const SizedBox(height: 10),

                // Privacy Policy Tile
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.policy_rounded, color: AppTheme.forestGreen),
                  title: const Text('Privacy Policy & Host Terms', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('DPDP Act compliance, space liability, & payouts'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/privacy-policy', extra: 1),
                ),

                const SizedBox(height: 24),

                Text(
                  'Account Controls',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),

                // Super Admin Console Tile
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.forestGreen),
                  title: const Text('Super Admin Developer Console', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Review & approve pending facilities, view stats'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/super-admin'),
                ),

                const SizedBox(height: 10),

                // Switch Role Tile
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.amber),
                  title: const Text('Switch to Driver (Seeker) Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Find and book parking spots as a driver'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () async {
                    await UserStateService.instance.switchRole(UserRole.seeker);
                    if (context.mounted) {
                      SweetPopup.show(
                        context,
                        title: 'Switched to Driver Mode',
                        message: 'Welcome back to driver mode.',
                        icon: Icons.directions_car_rounded,
                      );
                      context.go('/home');
                    }
                  },
                ),

                const SizedBox(height: 10),

                // Logout Tile
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  title: const Text('Log Out of ParkSync', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.error)),
                  subtitle: const Text('Sign out of your active host session'),
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
                ),

                const SizedBox(height: 32),

                Center(
                  child: Text(
                    'ParkSync Host Portal • v1.0.0 (Enterprise Build)',
                    style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
