import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final int initialTab;
  const PrivacyPolicyScreen({super.key, this.initialTab = 0});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          _activeTab == 0 ? 'Privacy Policy' : 'Terms of Service',
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
            // Tab Switcher
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
                          ),
                          child: Center(
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontWeight: _activeTab == 0 ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 13,
                                color: _activeTab == 0
                                    ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
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
                          ),
                          child: Center(
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontWeight: _activeTab == 1 ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 13,
                                color: _activeTab == 1
                                    ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
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
                    ? _buildPrivacyContent(isDark)
                    : _buildTermsContent(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Last Updated: October 2026 • DPDP Act Compliant (India)', isDark),
        const SizedBox(height: 12),
        _buildParagraph(
          'ParkSync ("we", "our", or "platform") respects your personal privacy. This policy outlines how information is gathered, safeguarded, and processed across our parking marketplace for Drivers (Seekers) and Space Hosts (Providers).',
          isDark,
        ),

        _buildPolicySection(
          title: '1. Information We Collect',
          content: [
            '• Phone Number & Verification: Collected via OTP verification for account authentication and transactional SMS receipts.',
            '• Vehicle Identity (RC): Vehicle make, model, year, dimensions, and registration plate number to perform auto-compatibility checks against parking bay clearances.',
            '• Location Data: Contextually accessed when you tap "Auto-detect my location" or start live turn-by-turn navigation to a reserved bay. Background location is never tracked outside active sessions.',
            '• Evidence Photos: Check-in and check-out photos voluntarily captured to record parked vehicle condition and resolve any damage claims.',
          ],
          icon: Icons.data_usage_rounded,
          isDark: isDark,
        ),

        _buildPolicySection(
          title: '2. How Information is Used',
          content: [
            '• To calculate physical dimension compatibility between vehicle types and listed parking slots.',
            '• To transmit reservation vouchers to parking providers and confirm entry check-ins.',
            '• To securely process escrow payouts to host bank accounts upon session completion.',
            '• We NEVER sell, lease, or monetize your contact details to third-party telemarketers or external advertisers.',
          ],
          icon: Icons.security_rounded,
          isDark: isDark,
        ),

        _buildPolicySection(
          title: '3. Data Retention & Deletion Rights',
          content: [
            '• You retain full ownership of your data under the Indian Digital Personal Data Protection (DPDP) Act.',
            '• You may request permanent deletion of your profile, vehicle records, and past parking logs directly via our customer support desk.',
          ],
          icon: Icons.delete_sweep_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTermsContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ParkSync Marketplace Rules & Terms of Service', isDark),
        const SizedBox(height: 12),
        _buildParagraph(
          'By accessing or utilizing the ParkSync mobile application, you agree to comply with the terms below governing both parking reservations and host space listing obligations.',
          isDark,
        ),

        _buildPolicySection(
          title: '1. Driver (Seeker) Obligations',
          content: [
            '• Punctuality & Overstay: Drivers must vacate the reserved bay on or before their scheduled session end time or extend via the app before expiry.',
            '• Lawful Parking: Vehicles must be lawfully registered and parked squarely within the designated markings or instructed bay.',
            '• Photo Evidence: Taking entry and exit photos is recommended. ParkSync uses timestamped photos to settle any property damage or overstay disputes.',
          ],
          icon: Icons.directions_car_rounded,
          isDark: isDark,
        ),

        _buildPolicySection(
          title: '2. Host (Provider) Obligations',
          content: [
            '• Space Ownership: Hosts certify that they own or hold authorized legal rights to monetize and lease the listed parking bay.',
            '• Unrestricted Access: Hosts must ensure the reserved bay is clear, accessible, and unobstructed for the entire duration of a confirmed booking.',
            '• Accurate Listings: Bay measurements, height clearance, and amenities (e.g. CCTV, EV chargers) must accurately reflect real facility conditions.',
          ],
          icon: Icons.storefront_rounded,
          isDark: isDark,
        ),

        _buildPolicySection(
          title: '3. Cancellation, Refunds & Dispute Settlement',
          content: [
            '• Free Cancellation: Reservations cancelled at least 30 minutes before arrival receive a 100% instant refund.',
            '• Host Guarantee: In the event of facility obstruction, drivers are provided an emergency nearby relocation or full compensation.',
            '• Escrow Protection: Payouts are held in escrow and credited to the host wallet immediately upon smooth checkout.',
          ],
          icon: Icons.account_balance_wallet_rounded,
          isDark: isDark,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF143B33) : const Color(0xFFEFE8D0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required List<String> content,
    required IconData icon,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: NeumorphicCard(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...content.map((point) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  point,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
