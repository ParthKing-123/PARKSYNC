import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/animated_floating_background.dart';
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
        // Go to logged-in home
        context.go('/home');
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

                // Pill
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
                      const Icon(Icons.verified_user_outlined,
                          size: 14, color: AppTheme.cyan),
                      const SizedBox(width: 6),
                      Text(
                        'One-Time Password',
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
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 44),

                // OTP Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgInput,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1C2A42)),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      letterSpacing: 22,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cyan,
                    ),
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                      color: AppTheme.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Development hint: Enter 123456 to test',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const CarLoadingIndicator(size: 28)
                      : Text(isEn ? l.verifyAndContinue : 'Verify & Continue'),
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
