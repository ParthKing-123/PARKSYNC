import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/animated_floating_background.dart';
import '../../../../shared/widgets/country_picker_modal.dart';
import 'package:parksync/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Standard E.164 phone format
    final fullNumber = '${_selectedCountry.dialCode}$rawNumber';

    // Simulate quick network check
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/verify-otp', extra: fullNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
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
                const SizedBox(height: 12),

                // Pill Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.cyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Secure Authentication',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isEn ? l.letsGetStarted : "Let's get\nstarted.",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEn
                      ? l.enterPhoneDesc
                      : 'Enter your phone number to receive a verification code.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 40),

                // International Phone Input Box
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgInput,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1C2A42)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // Country Code Selector Button
                      InkWell(
                        onTap: _chooseCountry,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1C2A42)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCountry.dialCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Phone Number Input
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(14),
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: isEn ? l.mobileNumber : 'Mobile Number',
                            hintStyle: const TextStyle(
                              color: AppTheme.textMuted,
                              letterSpacing: 0,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Standard carrier SMS rates apply • Instant OTP',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

                const Spacer(),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const CarLoadingIndicator(size: 28)
                      : Text(isEn ? l.continueText : 'Continue'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
