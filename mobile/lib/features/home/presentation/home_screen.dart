import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'ParkSync',
          style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Booking Mock for testing Phase 6
                  GestureDetector(
                    onTap: () {
                      context.push('/capture-evidence', extra: {'bookingId': 'mock123', 'type': 'BEFORE'});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.car_rental, color: Colors.black, size: 36),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Booking',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to capture BEFORE photo',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Text(
                    'Find parking.\nSkip the search.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Search Input Mock
                  GestureDetector(
                    onTap: () => context.push('/search', extra: 'Baner, Pune'),
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ]
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Where are you going?',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Theme.of(context).colorScheme.background,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Vehicle Selector Mock
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.directions_car_rounded, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Vehicle',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hyundai Creta 2024',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  Text(
                    'Nearby spots',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Placeholder Empty State
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Scanning for spots...',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        elevation: 0,
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
