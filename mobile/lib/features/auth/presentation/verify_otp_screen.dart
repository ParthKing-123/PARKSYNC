import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_client.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  
  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verify() async {
    if (_otpController.text.length != 6) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiClient().dio.post('/auth/verify', data: {
        'phone': widget.phoneNumber,
        'otp': _otpController.text,
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response.data['token']);
      
      if (mounted) {
        context.go('/add-vehicle');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Verification failed';
        if (e is DioException) {
          errorMsg = 'Dio Error: ${e.message}';
        } else {
          errorMsg = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your\nnumber',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to +91 ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(letterSpacing: 24, fontSize: 24),
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Verify & Continue'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
