import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final Object? bookingData;
  const BookingCheckoutScreen({super.key, this.bookingData});

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  bool _isLoading = false;

  void _processPayment(String amount) async {
    setState(() => _isLoading = true);
    // Simulate payment gateway processing
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _isLoading = false);

    if (mounted) {
      context.push('/booking-confirmation', extra: 'BK-AB12CD');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract passed booking metadata
    String parkingName = 'Metro Grand Parking Bay';
    String date = 'Today';
    String slot = '10:00 AM';
    String duration = '2 Hours';
    String totalAmount = '₹110.00';

    if (widget.bookingData is Map<String, dynamic>) {
      final data = widget.bookingData as Map<String, dynamic>;
      parkingName = data['parkingName'] ?? parkingName;
      date = data['date'] ?? date;
      slot = data['slot'] ?? slot;
      duration = data['duration'] ?? duration;
      totalAmount = data['amount'] ?? totalAmount;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Confirm & Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spot Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parkingName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: AppTheme.cyan),
                        const SizedBox(width: 6),
                        Text(
                          '$date • $slot ($duration)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Price Breakdown Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 14),
                    _buildPriceRow('Parking Spot Fee', '₹100.00'),
                    const SizedBox(height: 8),
                    _buildPriceRow('Platform & Security Fee', '₹10.00'),
                    const SizedBox(height: 8),
                    _buildPriceRow('GST (Inclusive)', '₹0.00'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          totalAmount,
                          style: TextStyle(
                            color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment method selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppTheme.success, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPI / Instant Pay',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('Google Pay, PhonePe, Paytm, Cards',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppTheme.cyan, size: 20),
                  ],
                ),
              ),

              const Spacer(),

              // Pay CTA Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _processPayment(totalAmount),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text('Pay $totalAmount & Reserve Bay'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
