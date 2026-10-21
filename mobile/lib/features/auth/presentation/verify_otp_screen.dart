import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/animated_floating_background.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../../shared/widgets/sweet_popup.dart';
import 'package:parksync/l10n/app_localizations.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().dio.post('/auth/verify', data: {
        'phone': widget.phoneNumber,
        'otp': _otpController.text,
      });

      final prefs = await SharedPreferences.getInstance();
      if (response.data['token'] != null) {
        await prefs.setString('jwt_token', response.data['token']);
      }

      if (mounted) {
        SweetPopup.show(
          context,
          title: 'Welcome to ParkSync!',
          message: 'Phone verified successfully.',
          icon: Icons.check_circle_rounded,
          iconColor: AppTheme.success,
        );
        // Small delay so user sees sweet welcome toast
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Verification failed. Try again.';
        if (e is DioException) {
          if (e.response?.data is Map && e.response?.data['error'] != null) {
            errorMsg = e.response?.data['error'].toString() ?? errorMsg;
          } else {
            errorMsg = e.message ?? errorMsg;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              onTap: () => context.pop(),
            ),
          ),
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

                // Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 14, color: AppTheme.forestGreen),
                      const SizedBox(width: 6),
                      Text(
                        'One-Time Password',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isEn ? l.verifyYourNumber : 'Verify your\nnumber.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEn
                      ? l.enterOtpDesc(widget.phoneNumber)
                      : 'Enter the 6-digit code sent to ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 40),

                // OTP Box
                NeumorphicCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  radius: 18,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      letterSpacing: 22,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      hintStyle: TextStyle(
                        letterSpacing: 22,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onChanged: (val) {
                      if (val.length == 6) {
                        _verify();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Mock helper hint in dev mode
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      ),
                    ),
                    child: Text(
                      'Development hint: Enter 123456 to test',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),

                const Spacer(),

                NeumorphicButton(
                  height: 52,
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const CarLoadingIndicator(size: 28)
                      : Text(isEn ? l.verifyAndContinue : 'Verify & Continue',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
