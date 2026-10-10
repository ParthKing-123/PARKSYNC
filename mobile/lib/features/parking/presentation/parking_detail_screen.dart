import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParkingDetailScreen extends StatelessWidget {
  final String parkingId;
  const ParkingDetailScreen({super.key, required this.parkingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.surface, // Fallback for image
                child: Center(
                  child: Icon(
                    Icons.local_parking,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Baner Premium Parking',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹40/hr',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('0.4 km away • Baner, Pune', style: Theme.of(context).textTheme.bodyMedium),
                  
                  const SizedBox(height: 24),
                  // Compatibility Check
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Hyundai Creta', style: Theme.of(context).textTheme.bodySmall),
                              const Text('Fits this parking space ✓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Text('Features', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildFeatureRow(context, Icons.roofing, 'Covered Parking'),
                  _buildFeatureRow(context, Icons.videocam, 'CCTV Surveillance'),
                  _buildFeatureRow(context, Icons.security, 'Security Guard'),
                  
                  const SizedBox(height: 32),
                  Text('Provider Info', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.business),
                    ),
                    title: const Text('Verified Office Building'),
                    subtitle: const Text('Business Verified • Parking Verified'),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom CTA
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).colorScheme.background,
        child: ElevatedButton(
          onPressed: () {
            context.push('/booking-checkout', extra: parkingId);
          },
          child: const Text('Select Time & Book'),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 16),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
