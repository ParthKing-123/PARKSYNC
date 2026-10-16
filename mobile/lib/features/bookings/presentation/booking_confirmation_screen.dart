import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingRef;
  const BookingConfirmationScreen({super.key, required this.bookingRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 64, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Metro Grand Parking Bay • $bookingRef',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 48),
              
              // Mock QR Code
              Container(
                width: 200,
                height: 200,
                color: Colors.white,
                child: Center(
                  child: Icon(Icons.qr_code_2, size: 180, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Scan this at the entrance'),
              
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
