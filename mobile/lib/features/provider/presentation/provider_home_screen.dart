import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import './provider_bookings_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _ProviderDashboardView(), // Home
    const Center(child: Text('Your Listings (Coming Soon)')),
    const ProviderBookingsScreen(), // Bookings
    const Center(child: Text('Profile Settings (Coming Soon)')),
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProviderDashboardView extends StatelessWidget {
  const _ProviderDashboardView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Host Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Center(
              child: NeumorphicIconBadge(
                icon: Icons.exit_to_app_rounded,
                size: 38,
                iconSize: 18,
                onTap: () => context.go('/home'),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earnings Summary
              NeumorphicCard(
                padding: const EdgeInsets.all(24),
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Earnings', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '₹0.00',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            fontSize: 36,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Verification pending. Listings are not live.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your Listings',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              NeumorphicCard(
                radius: 18,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_parking_rounded, color: AppTheme.forestGreen, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Central Commercial Parking', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('₹40/hr • 10 Spaces', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
