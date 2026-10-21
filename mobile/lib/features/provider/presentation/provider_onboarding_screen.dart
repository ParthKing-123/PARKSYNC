import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class ProviderOnboardingScreen extends StatelessWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Offer Parking',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'What type of parking provider are you?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us set up the right verification and rules for your listing across India.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildProviderTypeCard(
                      context,
                      title: 'Restaurant / Café',
                      description: 'Offer unused customer parking slots for shoppers and diners.',
                      icon: Icons.restaurant_rounded,
                      providerType: 'RESTAURANT',
                    ),
                    const SizedBox(height: 14),
                    _buildProviderTypeCard(
                      context,
                      title: 'Office / Corporate',
                      description: 'Monetize empty employee parking during weekends or nights.',
                      icon: Icons.business_rounded,
                      providerType: 'OFFICE',
                    ),
                    const SizedBox(height: 14),
                    _buildProviderTypeCard(
                      context,
                      title: 'Personal / Private',
                      description: 'List your private driveway or allotted residential slot.',
                      icon: Icons.home_rounded,
                      providerType: 'INDIVIDUAL',
                    ),
                    const SizedBox(height: 14),
                    _buildProviderTypeCard(
                      context,
                      title: 'Commercial Complex / Other',
                      description: 'Hotel, Mall, Hospital, or Educational Institution parking bays.',
                      icon: Icons.domain_rounded,
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
    return NeumorphicCard(
      radius: 18,
      padding: const EdgeInsets.all(18.0),
      onTap: () {
        context.push('/add-parking', extra: providerType);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.forestGreen,
              size: 26,
            ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
