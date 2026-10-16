import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/animated_floating_background.dart';
import 'package:parksync/l10n/app_localizations.dart';

/// Informational guide explaining the two personas (Buyer/Driver vs Seller/Provider)
/// with seamless deep links to explore parking or list a space.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/guest-home'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedFloatingBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isEn ? l.howItWorks : 'How ParkSync Works',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Two ways to\nuse ParkSync.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Whether you need a guaranteed parking spot or have extra bays to monetize, ParkSync connects drivers and hosts seamlessly.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 36),

                // Card 1: Driver Persona
                _PersonaCard(
                  title: isEn ? l.forDrivers : 'Find & Reserve Parking',
                  subtitle: 'FOR DRIVERS',
                  description: isEn
                      ? l.forDriversDesc
                      : 'Search, navigate, and book verified parking bays across India with guaranteed space and live status.',
                  icon: Icons.directions_car_rounded,
                  accentColor: AppTheme.cyan,
                  buttonText: isEn ? l.exploreParking : 'Explore Parking',
                  onTap: () => context.go('/guest-home'),
                ),

                const SizedBox(height: 18),

                // Card 2: Provider Persona
                _PersonaCard(
                  title: isEn ? l.forProviders : 'List & Monetize Bays',
                  subtitle: 'FOR HOSTS & BUSINESSES',
                  description: isEn
                      ? l.forProvidersDesc
                      : 'Turn empty driveways, restaurant slots, or corporate basements into passive income.',
                  icon: Icons.storefront_rounded,
                  accentColor: AppTheme.violet,
                  buttonText: isEn ? l.listYourSpace : 'List Your Space',
                  onTap: () => context.push('/provider-onboarding'),
                ),

                const Spacer(),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/guest-home'),
                    child: const Text('Continue to Marketplace →'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String buttonText;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.buttonText,
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
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: accentColor, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
