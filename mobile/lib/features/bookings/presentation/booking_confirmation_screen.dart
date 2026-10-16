import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Object? bookingData;
  const BookingConfirmationScreen({super.key, this.bookingData});

  @override
  Widget build(BuildContext context) {
    String bookingRef = 'PS-8924';
    String parkingName = 'Metro Grand Parking Bay';
    String date = 'Today';
    String slot = '10:00 AM to 10:47 AM';
    String duration = '47 Mins';
    String amount = '₹49.17';

    if (bookingData is Map<String, dynamic>) {
      final map = bookingData as Map<String, dynamic>;
      bookingRef = map['bookingRef'] ?? bookingRef;
      parkingName = map['parkingName'] ?? parkingName;
      date = map['date'] ?? date;
      slot = map['slot'] ?? slot;
      duration = map['duration'] ?? duration;
      amount = map['amount'] ?? amount;
    } else if (bookingData is String) {
      bookingRef = bookingData as String;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon Badge
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 20),

              // Exact message requested by the user
              Text(
                'Your booking was successful.',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Confirmed by Parking Host • Bay A4 Reserved',
                style: TextStyle(
                  color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              // Booking Pass Details Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          parkingName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CONFIRMED ✓',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date', date),
                    const SizedBox(height: 6),
                    _buildDetailRow('Time Window', slot),
                    const SizedBox(height: 6),
                    _buildDetailRow('Duration', duration),
                    const SizedBox(height: 6),
                    _buildDetailRow('Amount Paid', amount, isBold: true),
                    const SizedBox(height: 6),
                    _buildDetailRow('Booking Reference', bookingRef),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR Code Card for Entry
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black),
                    const SizedBox(height: 4),
                    Text(
                      'Scan at entry barrier to open bay gate',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.push(
                          '/capture-evidence',
                          extra: {'bookingId': bookingRef, 'type': 'BEFORE'},
                        );
                      },
                      child: const Text('Capture Photo', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Go to Home', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
