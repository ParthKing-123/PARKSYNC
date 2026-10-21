import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class BookingItemData {
  final String id;
  final String spotName;
  final String date;
  final String timeSlot;
  final String duration;
  final String amount;
  final String driverName;
  final String driverEmail;
  final String driverPhone;
  final double driverRating;
  final int driverTripCount;
  final bool isDriverPlatformVerified;
  final String vehicleModel;
  final String vehiclePlate;
  final bool isVehicleVerified;
  final String vehicleType;
  String status; // 'PENDING', 'ACTIVE', 'COMPLETED', 'DECLINED'

  BookingItemData({
    required this.id,
    required this.spotName,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.amount,
    required this.driverName,
    required this.driverEmail,
    required this.driverPhone,
    required this.driverRating,
    required this.driverTripCount,
    required this.isDriverPlatformVerified,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.isVehicleVerified,
    required this.vehicleType,
    required this.status,
  });
}

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'PENDING', 'ACTIVE', 'COMPLETED'

  final List<BookingItemData> _bookings = [
    BookingItemData(
      id: 'BK-9481IND',
      spotName: 'Metro Grand Premium Covered Slot #A-14',
      date: 'Today, 17 Oct',
      timeSlot: '10:30 AM - 01:15 PM',
      duration: '2h 45m',
      amount: '₹110.00',
      driverName: 'Parth Sharma',
      driverEmail: 'parth.sharma@gmail.com',
      driverPhone: '+91 98765 43210',
      driverRating: 4.95,
      driverTripCount: 24,
      isDriverPlatformVerified: true,
      vehicleModel: 'Hyundai Creta (White)',
      vehiclePlate: 'DL 01 AB 1234',
      isVehicleVerified: true,
      vehicleType: 'Compact SUV',
      status: 'PENDING',
    ),
    BookingItemData(
      id: 'BK-8273IND',
      spotName: 'Koramangala Safe Garage #B-03',
      date: 'Tomorrow, 18 Oct',
      timeSlot: '02:00 PM - 05:30 PM',
      duration: '3h 30m',
      amount: '₹140.00',
      driverName: 'Rohan Verma',
      driverEmail: 'rohan.verma99@gmail.com',
      driverPhone: '+91 98112 23344',
      driverRating: 4.80,
      driverTripCount: 11,
      isDriverPlatformVerified: true,
      vehicleModel: 'Tata Nexon EV (Teal)',
      vehiclePlate: 'MH 12 CD 5678',
      isVehicleVerified: true,
      vehicleType: 'Electric SUV',
      status: 'PENDING',
    ),
    BookingItemData(
      id: 'BK-7190IND',
      spotName: 'Connaught Place Basement #C-08',
      date: 'Today, 17 Oct',
      timeSlot: '08:00 AM - 12:00 PM',
      duration: '4h 00m',
      amount: '₹240.00',
      driverName: 'Ananya Iyer',
      driverEmail: 'ananya.iyer@gmail.com',
      driverPhone: '+91 97654 11223',
      driverRating: 5.0,
      driverTripCount: 39,
      isDriverPlatformVerified: true,
      vehicleModel: 'Maruti Swift (Silver)',
      vehiclePlate: 'KA 03 EF 9988',
      isVehicleVerified: true,
      vehicleType: 'Hatchback',
      status: 'ACTIVE',
    ),
    BookingItemData(
      id: 'BK-6045IND',
      spotName: 'Bandra West Secure Bay #D-02',
      date: '15 Oct 2026',
      timeSlot: '09:00 AM - 12:00 PM',
      duration: '3h 00m',
      amount: '₹180.00',
      driverName: 'Vikram Malhotra',
      driverEmail: 'vikram.m@gmail.com',
      driverPhone: '+91 99887 66554',
      driverRating: 4.70,
      driverTripCount: 8,
      isDriverPlatformVerified: true,
      vehicleModel: 'Kia Seltos (Black)',
      vehiclePlate: 'MH 02 XY 1020',
      isVehicleVerified: true,
      vehicleType: 'SUV',
      status: 'COMPLETED',
    ),
  ];

  List<BookingItemData> get _filteredBookings {
    if (_selectedFilter == 'ALL') return _bookings;
    return _bookings.where((b) => b.status == _selectedFilter).toList();
  }

  int get _pendingCount => _bookings.where((b) => b.status == 'PENDING').length;

  void _approveBooking(BookingItemData booking) {
    setState(() {
      booking.status = 'ACTIVE';
    });
    SweetPopup.show(
      context,
      title: 'Booking Approved!',
      message: '${booking.driverName} has been sent their verified digital parking pass.',
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.success,
    );
  }

  void _declineBooking(BookingItemData booking) {
    setState(() {
      booking.status = 'DECLINED';
    });
    SweetPopup.show(
      context,
      title: 'Booking Declined',
      message: 'Request ${booking.id} has been declined.',
      icon: Icons.cancel_rounded,
      iconColor: AppTheme.error,
    );
  }

  void _completeBooking(BookingItemData booking) {
    setState(() {
      booking.status = 'COMPLETED';
    });
    SweetPopup.show(
      context,
      title: 'Session Completed!',
      message: 'Payout of ${booking.amount} credited to your host wallet.',
      icon: Icons.task_alt_rounded,
      iconColor: AppTheme.forestGreen,
    );
  }

  void _showDriverContactDialog(BookingItemData booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.cyan.withValues(alpha: 0.15),
                    child: Text(
                      booking.driverName.substring(0, 1),
                      style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.driverName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 13, color: AppTheme.success),
                            SizedBox(width: 4),
                            Text(
                              'Platform Verified Driver',
                              style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18, color: AppTheme.cyan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.driverEmail,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Verified', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18, color: AppTheme.cyan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.driverPhone,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Active', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Starting SMS chat with ${booking.driverName}...')),
                        );
                      },
                      icon: const Icon(Icons.message_outlined, size: 16),
                      label: const Text('Send SMS'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Initiating call to ${booking.driverPhone}...')),
                        );
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: const Text('Call Driver'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Host Bookings Hub',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh requests',
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookings updated.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtitle info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Review driver identities, verified vehicles & manage incoming requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Segmented bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All (${_bookings.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'PENDING',
                  'Pending ($_pendingCount)',
                  hasAlert: _pendingCount > 0,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'ACTIVE',
                  'Active (${_bookings.where((b) => b.status == 'ACTIVE').length})',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'COMPLETED',
                  'History (${_bookings.where((b) => b.status == 'COMPLETED' || b.status == 'DECLINED').length})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Booking List
          Expanded(
            child: _filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 54, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No bookings in this category',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _buildBookingCard(context, booking, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {bool hasAlert = false}) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.cyan.withValues(alpha: 0.18)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.cyan
                : (Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAlert) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.cyan
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingItemData booking, bool isDark) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (booking.status) {
      case 'PENDING':
        statusColor = AppTheme.amber;
        statusLabel = 'CONFIRMATION PENDING';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'ACTIVE':
        statusColor = AppTheme.cyan;
        statusLabel = 'ACTIVE SPOT OCCUPIED';
        statusIcon = Icons.sensors_rounded;
        break;
      case 'COMPLETED':
        statusColor = AppTheme.success;
        statusLabel = 'COMPLETED';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'DECLINED':
      default:
        statusColor = AppTheme.error;
        statusLabel = 'DECLINED';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicCard(
        radius: 18,
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar: Spot & Status Badge ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.spotName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.id,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Time & Duration & Earnings Row ────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, size: 16, color: AppTheme.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.date} • ${booking.timeSlot}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        Text(
                          'Requested Duration: ${booking.duration}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Payout: ${booking.amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.cyan,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── DRIVER & USER IDENTITY CARD (User info on host side) ──────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.cyan.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DRIVER IDENTITY & VEHICLE DETAILS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppTheme.cyan,
                        ),
                      ),
                      if (booking.isDriverPlatformVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, size: 10, color: AppTheme.success),
                              SizedBox(width: 3),
                              Text(
                                'Platform Verified Driver ✓',
                                style: TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Driver Name & Rating
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.cyan.withValues(alpha: 0.15),
                        child: Text(
                          booking.driverName.substring(0, 1),
                          style: const TextStyle(
                            color: AppTheme.cyan,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.driverName,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: AppTheme.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${booking.driverRating} (${booking.driverTripCount} bookings)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Driver Gmail
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 14, color: AppTheme.cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.driverEmail,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                      const Text(
                        'Verified Gmail ✓',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Driver Phone
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppTheme.cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.driverPhone,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                      const Text(
                        'Phone Validated ✓',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Vehicle info
                  Row(
                    children: [
                      const Icon(Icons.directions_car_rounded, size: 14, color: AppTheme.cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.vehicleModel} • ${booking.vehiclePlate}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      if (booking.isVehicleVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RC Verified ✓',
                            style: TextStyle(
                              color: AppTheme.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── ACTION BUTTONS ────────────────────────────────────────────
            if (booking.status == 'PENDING') ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _declineBooking(booking),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: NeumorphicButton(
                      height: 44,
                      onPressed: () => _approveBooking(booking),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Approve Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (booking.status == 'ACTIVE') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showDriverContactDialog(booking),
                      icon: const Icon(Icons.contact_phone_outlined, size: 16),
                      label: const Text('Contact Driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeumorphicButton(
                      height: 44,
                      onPressed: () => _completeBooking(booking),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.done_all_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Complete Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (booking.status == 'COMPLETED') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Payout of ${booking.amount} settled to wallet',
                        style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showDriverContactDialog(booking),
                    child: const Text('View Driver Details', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ] else if (booking.status == 'DECLINED') ...[
              const Row(
                children: [
                  Icon(Icons.cancel_rounded, color: AppTheme.error, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Booking request was declined',
                    style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
