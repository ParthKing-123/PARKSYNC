import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final String parkingId;
  const BookingCheckoutScreen({super.key, required this.parkingId});

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  bool _isLoading = false;

  void _processPayment() async {
    setState(() => _isLoading = true);
    // Simulate gateway delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    
    if (mounted) {
      context.push('/booking-confirmation', extra: 'BK-AB12CD');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baner Premium Parking', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              Text('Today, 10:00 AM - 12:00 PM (2 Hours)', style: Theme.of(context).textTheme.bodyMedium),
              
              const SizedBox(height: 32),
              
              // Price breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Parking Fee (₹40 x 2)', '₹80.00'),
                    const SizedBox(height: 8),
                    _buildPriceRow('Platform Fee', '₹8.00'),
                    const Divider(height: 24),
                    _buildPriceRow('Total', '₹88.00', isTotal: true),
                  ],
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Pay ₹88.00'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
