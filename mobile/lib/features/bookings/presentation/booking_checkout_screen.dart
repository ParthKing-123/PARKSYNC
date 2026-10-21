import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final Object? bookingData;
  const BookingCheckoutScreen({super.key, this.bookingData});

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  // Booking lifecycle states: IDLE -> SENDING -> AWAITING_HOST -> APPROVED
  String _approvalState = 'IDLE';

  void _sendRequestToHost(String parkingName, String totalAmount, String date, String slot, String duration) async {
    setState(() => _approvalState = 'SENDING');

    // 1. Dispatching request
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _approvalState = 'AWAITING_HOST');

    // 2. Host reviews and confirms
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    setState(() => _approvalState = 'APPROVED');
    SweetPopup.show(
      context,
      title: 'Booking Approved!',
      message: 'Host has accepted your parking bay reservation.',
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.success,
    );

    // 3. Navigate to confirmation screen
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    context.push(
      '/booking-confirmation',
      extra: {
        'bookingRef': 'PS-8924',
        'parkingName': parkingName,
        'date': date,
        'slot': slot,
        'duration': duration,
        'amount': totalAmount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String parkingName = 'Metro Grand Parking Bay';
    String date = 'Today';
    String slot = '10:00 AM to 10:47 AM';
    String duration = '47 Mins';
    String totalAmount = '₹49.17';

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
        title: const Text('Review Booking Request'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: _approvalState == 'IDLE' ? () => context.pop() : null,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spot & Custom Time Card
              NeumorphicCard(
                padding: const EdgeInsets.all(18),
                radius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            parkingName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Host Online ●',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 15, color: AppTheme.forestGreen),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 15, color: AppTheme.forestGreen),
                        const SizedBox(width: 8),
                        Text(
                          '$slot ($duration)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Host Approval Status Banner
              if (_approvalState != 'IDLE')
                NeumorphicCard(
                  radius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_approvalState == 'SENDING') ...[
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Sending booking request to parking host...',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ] else if (_approvalState == 'AWAITING_HOST') ...[
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Host reviewing request...',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Metro Grand Host is confirming bay allocation',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_approvalState == 'APPROVED') ...[
                        const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 24),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Host Confirmed Request!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppTheme.success,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Finalizing reservation details...',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // Payment Summary
              NeumorphicCard(
                padding: const EdgeInsets.all(18),
                radius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment & Rate Breakdown',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRow('Parking Spot Duration', duration),
                    const SizedBox(height: 6),
                    _buildPriceRow('Pro-rata Spot Charge', '₹${(double.tryParse(totalAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 49.17) - 10.0}'),
                    const SizedBox(height: 6),
                    _buildPriceRow('Host Protection & Platform Fee', '₹10.00'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Text(
                          totalAmount,
                          style: TextStyle(
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Host Guarantee Banner
              NeumorphicCard(
                padding: const EdgeInsets.all(14),
                radius: 14,
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 20, color: AppTheme.forestGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Host confirmation is required. You will only be charged after the host confirms your reservation.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Submit Button
              NeumorphicButton(
                height: 50,
                onPressed: _approvalState == 'IDLE'
                    ? () => _sendRequestToHost(parkingName, totalAmount, date, slot, duration)
                    : null,
                child: _approvalState == 'IDLE'
                    ? Text('Send Booking Request to Host • $totalAmount', style: const TextStyle(fontWeight: FontWeight.w700))
                    : const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
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
            fontSize: 12,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
