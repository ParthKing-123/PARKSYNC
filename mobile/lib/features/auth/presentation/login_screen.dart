import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/animated_floating_background.dart';
import '../../../../shared/widgets/country_picker_modal.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../../shared/widgets/sweet_popup.dart';
import 'package:parksync/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  int _selectedTabIndex = 0; // 0 = Seeker, 1 = Provider

  Country _selectedCountry = const Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flag: '🇮🇳',
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _chooseCountry() async {
    final picked = await showCountryPickerDialog(
      context: context,
      initialCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  void _sendOtp() async {
    final rawNumber = _phoneController.text.trim();
    if (rawNumber.length < 6) {
      SweetPopup.show(
        context,
        title: 'Invalid Phone Number',
        message: 'Please enter a valid mobile number to continue.',
        icon: Icons.phone_disabled_rounded,
        iconColor: AppTheme.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Standard E.164 phone format
    final fullNumber = '${_selectedCountry.dialCode}$rawNumber';
    final role = _selectedTabIndex == 0 ? 'seeker' : 'provider';
    String? verificationId;

    try {
      final response = await ApiClient().dio.post('/auth/send-otp', data: {
        'phone': fullNumber,
        'role': role,
      });

      if (response.data != null && response.data['verificationId'] != null) {
        verificationId = response.data['verificationId'].toString();
      }

      final msg = response.data?['message']?.toString() ?? 'OTP sent to $fullNumber';
      if (mounted) {
        SweetPopup.show(
          context,
          title: 'Code Sent!',
          message: msg,
          icon: Icons.sms_rounded,
          iconColor: AppTheme.success,
        );
      }
    } catch (e) {
      debugPrint('[Auth] Backend unreachable, using offline dev mode: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.push(
        '/verify-otp',
        extra: {
          'phone': fullNumber,
          'role': role,
          'verificationId': verificationId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/guest-home');
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/user-guide'),
            icon: Icon(
              Icons.help_outline_rounded,
              size: 16,
              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
            ),
            label: Text(
              'User Guide',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedFloatingBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Top circular logo badge
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.forestSurface : AppTheme.forestGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppTheme.accentGold : AppTheme.butter,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppTheme.forestGreen).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _selectedTabIndex == 0
                            ? Icons.directions_car_rounded
                            : Icons.storefront_rounded,
                        size: 32,
                        color: isDark ? AppTheme.butter : AppTheme.butter,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // App Title
                Text(
                  'ParkSync',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart Parking Marketplace System',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // ── Central Authentication Card ─────────────────────────────
                NeumorphicCard(
                  radius: 22,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header inside card
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Login to Your Account',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose your account type to continue',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Sliding Role Tabs (Matching reference layout) ─────
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerTheme.color ??
                                  (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Member / Parking Seeker Tab
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedTabIndex = 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_pin_circle_rounded,
                                            size: 16,
                                            color: _selectedTabIndex == 0
                                                ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                                : Theme.of(context).colorScheme.outline,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Parking Seeker',
                                            style: TextStyle(
                                              fontWeight: _selectedTabIndex == 0
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              fontSize: 13,
                                              color: _selectedTabIndex == 0
                                                  ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                                  : Theme.of(context).colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 3,
                                        width: _selectedTabIndex == 0 ? 90 : 0,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Admin / Parking Provider Tab
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedTabIndex = 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.storefront_rounded,
                                            size: 16,
                                            color: _selectedTabIndex == 1
                                                ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                                : Theme.of(context).colorScheme.outline,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Parking Provider',
                                            style: TextStyle(
                                              fontWeight: _selectedTabIndex == 1
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              fontSize: 13,
                                              color: _selectedTabIndex == 1
                                                  ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                                  : Theme.of(context).colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 3,
                                        width: _selectedTabIndex == 1 ? 90 : 0,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                          borderRadius: BorderRadius.circular(2),
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

                      const SizedBox(height: 20),

                      // Informational badge for role
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.forestElevated : AppTheme.forestGreen.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF23695B).withValues(alpha: 0.5)
                                : AppTheme.borderLight,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedTabIndex == 0
                                  ? Icons.directions_car_rounded
                                  : Icons.verified_user_rounded,
                              size: 16,
                              color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedTabIndex == 0
                                    ? 'Find, reserve, and navigate to guaranteed parking bays across India.'
                                    : 'Monetize driveways, commercial basements, or vacant parking spaces.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Phone Input Field
                      Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).dividerTheme.color ??
                                (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Row(
                          children: [
                            // Country Code Selector Button
                            InkWell(
                              onTap: _chooseCountry,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedCountry.dialCode,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              height: 24,
                              width: 1,
                              color: Theme.of(context).dividerTheme.color ??
                                  (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),

                            // Phone Number Input
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(14),
                                ],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: isEn ? l.mobileNumber : '98765 43210',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.outline,
                                    letterSpacing: 0,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 13, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 6),
                          Text(
                            'Instant SMS verification code',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Submit Button
                      NeumorphicButton(
                        height: 48,
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading
                            ? const CarLoadingIndicator(size: 26)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedTabIndex == 0
                                        ? Icons.login_rounded
                                        : Icons.storefront_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedTabIndex == 0
                                        ? 'Login as Parking Seeker'
                                        : 'Login as Parking Provider',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                ],
                              ),
                      ),

                      // ── Seeker Skip For Now Option (Requested by user) ─────
                      if (_selectedTabIndex == 0) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Guest explore without login
                              context.go('/guest-home');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Skip for now — Explore Parking',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Privacy & Terms footer links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.push('/privacy-policy'),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    Text('•', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                    TextButton(
                      onPressed: () => context.push('/privacy-policy', extra: 1), // Tab 1 = Terms
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    Text('•', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                    TextButton(
                      onPressed: () => context.push('/user-guide'),
                      child: Text(
                        'User Guide',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Footer statement
                Text(
                  'Empowering communities through seamless urban mobility',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
