import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderOnboardingScreen extends StatelessWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Parking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'What type of parking provider are you?',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us set up the right verification and rules for your listing.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildProviderTypeCard(
                      context,
                      title: 'Restaurant / Café',
                      description: 'Offer unused customer parking slots.',
                      icon: Icons.restaurant,
                      providerType: 'RESTAURANT',
                    ),
                    const SizedBox(height: 12),
                    _buildProviderTypeCard(
                      context,
                      title: 'Office / Corporate',
                      description: 'Monetize empty employee parking during weekends or nights.',
                      icon: Icons.business,
                      providerType: 'OFFICE',
                    ),
                    const SizedBox(height: 12),
                    _buildProviderTypeCard(
                      context,
                      title: 'Personal / Private',
                      description: 'List your private driveway or allotted slot.',
                      icon: Icons.home,
                      providerType: 'INDIVIDUAL',
                    ),
                    const SizedBox(height: 12),
                    _buildProviderTypeCard(
                      context,
                      title: 'Other Business',
                      description: 'Hotel, Mall, Hospital, or Educational Institution.',
                      icon: Icons.domain,
                      providerType: 'OTHER',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String providerType,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to add-parking setup flow
          context.push('/add-parking', extra: providerType);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
