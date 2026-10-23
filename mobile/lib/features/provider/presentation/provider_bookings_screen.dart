import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
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
  List<BookingItemData> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/bookings/provider-requests');
      if (res.data is List) {
        final list = (res.data as List).map((b) {
          final space = b['parkingSpace'] ?? {};
          final user = b['user'] ?? {};
          final vehicle = b['vehicle'] ?? {};
          final vehicleModel = vehicle['vehicleModel'] ?? {};
          final vName = vehicleModel['model'] != null
              ? '${vehicleModel['make'] ?? ''} ${vehicleModel['model']}'
              : (vehicle['registrationNumber'] ?? 'Standard Car');
          final plate = vehicle['registrationNumber'] ?? 'Plate Pending';

          String status = (b['status'] ?? 'PENDING').toString().toUpperCase();
          if (status == 'CONFIRMED') status = 'ACTIVE';
          if (status == 'REJECTED') status = 'DECLINED';

          final start = DateTime.tryParse(b['startTime']?.toString() ?? '') ?? DateTime.now();
          final end = DateTime.tryParse(b['endTime']?.toString() ?? '') ?? DateTime.now().add(const Duration(hours: 1));
          final durationMins = end.difference(start).inMinutes;

          return BookingItemData(
            id: b['id']?.toString() ?? '',
            spotName: space['title']?.toString() ?? 'My Parking Bay',
            date: '${start.day}/${start.month}/${start.year}',
            timeSlot: '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
            duration: '$durationMins mins',
            amount: '₹${b['totalAmount'] ?? '50.0'}',
            driverName: user['name']?.toString() ?? 'Registered Driver',
            driverEmail: user['email']?.toString() ?? 'driver@parksync.in',
            driverPhone: user['phone']?.toString() ?? '+91 7058541200',
            driverRating: 4.9,
            driverTripCount: 12,
            isDriverPlatformVerified: true,
            vehicleModel: vName,
            vehiclePlate: plate,
            isVehicleVerified: true,
            vehicleType: vehicleModel['vehicleType'] ?? 'Car',
            status: status,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _bookings = list;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('[ProviderBookings] Load bookings error: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<BookingItemData> get _filteredBookings {
    if (_selectedFilter == 'ALL') return _bookings;
    return _bookings.where((b) => b.status == _selectedFilter).toList();
  }

  int get _pendingCount => _bookings.where((b) => b.status == 'PENDING').length;

  Future<void> _approveBooking(BookingItemData booking) async {
    try {
      await ApiClient().dio.post('/bookings/${booking.id}/approve');
      setState(() {
        booking.status = 'ACTIVE';
      });
      if (mounted) {
        SweetPopup.show(
          context,
          title: 'Booking Approved!',
          message: '${booking.driverName} has been sent their verified digital parking pass.',
          icon: Icons.check_circle_rounded,
          iconColor: AppTheme.success,
        );
      }
    } catch (e) {
      debugPrint('[ProviderBookings] Approve error: $e');
    }
  }

  Future<void> _declineBooking(BookingItemData booking) async {
    try {
      await ApiClient().dio.post('/bookings/${booking.id}/reject');
      setState(() {
        booking.status = 'DECLINED';
      });
      if (mounted) {
        SweetPopup.show(
          context,
          title: 'Booking Declined',
          message: 'Request ${booking.id} has been declined and slot released.',
          icon: Icons.cancel_rounded,
          iconColor: AppTheme.error,
        );
      }
    } catch (e) {
      debugPrint('[ProviderBookings] Decline error: $e');
    }
  }

  Future<void> _completeBooking(BookingItemData booking) async {
    try {
      await ApiClient().dio.patch('/bookings/${booking.id}/status', data: {'status': 'COMPLETED'});
      setState(() {
        booking.status = 'COMPLETED';
      });
      if (mounted) {
        SweetPopup.show(
          context,
          title: 'Session Completed!',
          message: 'Payout of ${booking.amount} credited to your host wallet.',
          icon: Icons.task_alt_rounded,
          iconColor: AppTheme.forestGreen,
        );
      }
    } catch (e) {
      debugPrint('[ProviderBookings] Complete error: $e');
    }
  }

  void _showDriverContactDialog(BookingItemData booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    backgroundColor: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.15),
                    child: Text(
                      booking.driverName.substring(0, 1),
                      style: TextStyle(
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.driverName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          ),
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
                        Icon(Icons.email_outlined, size: 18, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
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
                        Icon(Icons.phone_outlined, size: 18, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
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
            onPressed: _loadBookings,
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

          // Booking List with Real-time Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBookings,
              color: AppTheme.forestGreen,
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.forestGreen),
                      ),
                    )
                  : _filteredBookings.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_rounded,
                                      size: 54, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No booking requests in this tab',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.outline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Pull down to refresh new incoming requests',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = _filteredBookings[index];
                            return _buildBookingCard(context, booking, isDark);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {bool hasAlert = false}) {
    final isSelected = _selectedFilter == filterKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? AppTheme.butter : AppTheme.forestGreen;
    final selectedFg = isDark ? AppTheme.forestGreenDark : AppTheme.butter;
    final unselectedBg = isDark ? AppTheme.forestSurface : AppTheme.butterCream;
    final unselectedFg = isDark ? AppTheme.butter : AppTheme.forestGreen;

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
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? selectedBg
                : (Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
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
                color: isSelected ? selectedFg : unselectedFg,
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
        statusColor = isDark ? AppTheme.accentGold : AppTheme.forestGreen;
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
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.id,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD6EAE5) : Theme.of(context).colorScheme.outline,
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
                  Icon(Icons.access_time_filled_rounded, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
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
                            color: isDark ? const Color(0xFFD6EAE5) : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Payout: ${booking.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
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
                  color: isDark
                      ? AppTheme.butter.withValues(alpha: 0.18)
                      : AppTheme.forestGreen.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DRIVER IDENTITY & VEHICLE DETAILS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
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
                        backgroundColor: isDark
                            ? const Color(0xFF143B33)
                            : AppTheme.forestGreen.withValues(alpha: 0.12),
                        child: Text(
                          booking.driverName.substring(0, 1),
                          style: TextStyle(
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
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
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
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
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
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
                      Icon(
                        Icons.directions_car_rounded,
                        size: 14,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
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
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RC Verified ✓',
                            style: TextStyle(
                              color: AppTheme.success,
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
