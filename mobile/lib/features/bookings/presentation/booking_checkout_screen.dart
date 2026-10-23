import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_client.dart';
import '../../../core/user_state_service.dart';
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
  // Booking lifecycle state: 'IDLE' | 'SUBMITTING' | 'REQUEST_SENT'
  String _pageState = 'IDLE';
  String _selectedPaymentMethod = 'CASH_ON_ARRIVAL'; // 'CASH_ON_ARRIVAL' or 'UPI'
  String? _generatedBookingRef;

  Future<void> _sendBookingRequest({
    required String parkingId,
    required String parkingName,
    required String totalAmount,
    required String date,
    required String slot,
    required String duration,
    String? startTimeIso,
    String? endTimeIso,
  }) async {
    setState(() => _pageState = 'SUBMITTING');

    final numAmount = double.tryParse(totalAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 40.0;
    final now = DateTime.now();
    final start = startTimeIso != null ? DateTime.tryParse(startTimeIso) ?? now : now;
    final end = endTimeIso != null ? DateTime.tryParse(endTimeIso) ?? now.add(const Duration(hours: 1)) : now.add(const Duration(hours: 1));

    final activeVehicle = UserStateService.instance.activeVehicle;
    final prefs = await SharedPreferences.getInstance();
    final vehiclePlate = activeVehicle?.plateNumber ?? prefs.getString('selected_vehicle_reg') ?? 'MH 12 AB 1234';
    final vehicleModel = activeVehicle != null ? '${activeVehicle.make} ${activeVehicle.model}' : 'Sedan';

    try {
      final response = await ApiClient().dio.post('/bookings', data: {
        'parkingSpaceId': parkingId,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'paymentMethod': _selectedPaymentMethod,
        'totalAmount': numAmount,
        'vehiclePlate': vehiclePlate,
        'vehicleModel': vehicleModel,
      });

      if (response.data != null) {
        final bRef = response.data['bookingReference']?.toString() ?? 'BK-REQ';
        setState(() {
          _generatedBookingRef = bRef;
          _pageState = 'REQUEST_SENT';
        });

        if (mounted) {
          SweetPopup.show(
            context,
            title: 'Booking Request Sent!',
            message: 'Your reservation request is now pending host approval.',
            icon: Icons.hourglass_top_rounded,
            iconColor: AppTheme.amber,
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('[BookingCheckout] Submit request error: $e');
      String errorMsg = 'Failed to submit request. Please try again.';
      if (e is DioException && e.response?.data is Map) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      if (mounted) {
        setState(() => _pageState = 'IDLE');
        SweetPopup.show(
          context,
          title: 'Request Failed',
          message: errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: AppTheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String parkingId = '';
    String parkingName = 'ParkSync Parking Bay';
    String date = 'Today';
    String slot = '10:00 AM to 11:00 AM';
    String duration = '60 Mins';
    String totalAmount = '₹50.00';
    String? startTimeIso;
    String? endTimeIso;

    if (widget.bookingData is Map<String, dynamic>) {
      final data = widget.bookingData as Map<String, dynamic>;
      parkingId = data['parkingId']?.toString() ?? '';
      parkingName = data['parkingName'] ?? parkingName;
      date = data['date'] ?? date;
      slot = data['slot'] ?? slot;
      duration = data['duration'] ?? duration;
      totalAmount = data['amount'] ?? totalAmount;
      startTimeIso = data['startTime']?.toString();
      endTimeIso = data['endTime']?.toString();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_pageState == 'REQUEST_SENT' ? 'Request Dispatched' : 'Review & Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _pageState == 'REQUEST_SENT'
            ? _buildSuccessView(context, parkingName, totalAmount, date, slot, isDark)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spot & Timing Card
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
                                  color: AppTheme.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Requires Approval',
                                  style: TextStyle(
                                    color: AppTheme.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 15, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
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
                              Icon(Icons.access_time_rounded, size: 15, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
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

                    // Payment Method Options (User Requirement: Cash on Arrival & UPI)
                    Text(
                      'Choose Payment Method *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Option 1: Cash on Arrival
                    NeumorphicCard(
                      onTap: () => setState(() => _selectedPaymentMethod = 'CASH_ON_ARRIVAL'),
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      border: _selectedPaymentMethod == 'CASH_ON_ARRIVAL'
                          ? Border.all(color: isDark ? AppTheme.accentGold : AppTheme.forestGreen, width: 2)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (_selectedPaymentMethod == 'CASH_ON_ARRIVAL')
                                  ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.payments_rounded,
                              size: 20,
                              color: (_selectedPaymentMethod == 'CASH_ON_ARRIVAL')
                                  ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on Arrival (Pay at Spot)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Pay cash directly to the host when checking in',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPaymentMethod == 'CASH_ON_ARRIVAL'
                                    ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: _selectedPaymentMethod == 'CASH_ON_ARRIVAL'
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Option 2: UPI Instant
                    NeumorphicCard(
                      onTap: () => setState(() => _selectedPaymentMethod = 'UPI'),
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      border: _selectedPaymentMethod == 'UPI'
                          ? Border.all(color: isDark ? AppTheme.accentGold : AppTheme.forestGreen, width: 2)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (_selectedPaymentMethod == 'UPI')
                                  ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                              color: (_selectedPaymentMethod == 'UPI')
                                  ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPI (GPay / PhonePe / Paytm / BHIM)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Instant zero-fee scan & pay to host QR',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPaymentMethod == 'UPI'
                                    ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: _selectedPaymentMethod == 'UPI'
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Price Summary
                    NeumorphicCard(
                      padding: const EdgeInsets.all(18),
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fare Breakdown',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow('Spot Duration', duration),
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

                    // Host Approval Notice
                    NeumorphicCard(
                      padding: const EdgeInsets.all(14),
                      radius: 14,
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 20, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Real-time host approval is required. Your payment is only due once the host accepts your bay request.',
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

                    const SizedBox(height: 28),

                    // Submit Request Button
                    NeumorphicButton(
                      height: 52,
                      onPressed: _pageState == 'IDLE'
                          ? () => _sendBookingRequest(
                                parkingId: parkingId,
                                parkingName: parkingName,
                                totalAmount: totalAmount,
                                date: date,
                                slot: slot,
                                duration: duration,
                                startTimeIso: startTimeIso,
                                endTimeIso: endTimeIso,
                              )
                          : null,
                      child: _pageState == 'IDLE'
                          ? Text(
                              'Request Booking from Host • $totalAmount',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            )
                          : const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    String parkingName,
    String totalAmount,
    String date,
    String slot,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_send_rounded, size: 40, color: AppTheme.amber),
          ),
          const SizedBox(height: 20),
          Text(
            'Booking Request Dispatched!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'The host has been notified. Once approved, your slot will be confirmed and host contact will be unlocked.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline, height: 1.4),
          ),
          const SizedBox(height: 24),

          NeumorphicCard(
            padding: const EdgeInsets.all(18),
            radius: 18,
            child: Column(
              children: [
                if (_generatedBookingRef != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Request Ref', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('#$_generatedBookingRef', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 18),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Parking Bay', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Expanded(
                      child: Text(
                        parkingName,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Schedule', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('$date, $slot', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Mode', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _selectedPaymentMethod == 'UPI' ? 'UPI Instant' : 'Cash on Arrival',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Awaiting Host Approval',
                        style: TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          NeumorphicButton(
            height: 50,
            onPressed: () {
              context.go('/home');
            },
            child: const Text('Back to Home / Explore', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
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
