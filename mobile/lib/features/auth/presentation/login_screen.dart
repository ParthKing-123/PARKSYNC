import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/animated_floating_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOtp() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    if (mounted) {
      context.push('/verify-otp', extra: _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedFloatingBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0), // increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Let\'s get\nstarted.',
                  style: Theme.of(context).textTheme.displayLarge, // Bigger text
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter your phone number to receive a verification code.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 56),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, letterSpacing: 1),
                  decoration: const InputDecoration(
                    hintText: 'Mobile Number',
                    prefixText: '+91  ',
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading 
                      ? const CarLoadingIndicator(size: 30)
                      : const Text('Continue'),
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
