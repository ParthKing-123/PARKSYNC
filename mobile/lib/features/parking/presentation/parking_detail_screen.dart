import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String parkingId;
  const ParkingDetailScreen({super.key, required this.parkingId});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  // Booking Parameters
  int _selectedDateIndex = 0;
  int _durationHours = 2;
  String _selectedSlot = '10:00 AM';

  final List<String> _dates = [
    'Today',
    'Tomorrow',
    'Fri, 17 Oct',
    'Sat, 18 Oct',
    'Sun, 19 Oct',
  ];

  final List<Map<String, dynamic>> _slots = [
    {'time': '08:00 AM', 'status': 'Available'},
    {'time': '09:00 AM', 'status': 'Available'},
    {'time': '10:00 AM', 'status': 'Available'},
    {'time': '11:00 AM', 'status': 'Filling Fast'},
    {'time': '12:00 PM', 'status': 'Available'},
    {'time': '01:00 PM', 'status': 'Available'},
    {'time': '02:00 PM', 'status': 'Filling Fast'},
    {'time': '03:00 PM', 'status': 'Available'},
    {'time': '04:00 PM', 'status': 'Available'},
    {'time': '05:00 PM', 'status': 'Available'},
    {'time': '06:00 PM', 'status': 'Reserved'},
    {'time': '07:00 PM', 'status': 'Available'},
  ];

  final int _hourlyRate = 50;

  int get _subtotal => _hourlyRate * _durationHours;
  int get _platformFee => 10;
  int get _totalAmount => _subtotal + _platformFee;

  void _openBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Date & Time Slot',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹$_hourlyRate/hr',
                          style: TextStyle(
                            color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. DATE SELECTION
                          const Text(
                            '1. CHOOSE DATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppTheme.cyan,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _dates.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final isSelected = i == _selectedDateIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() => _selectedDateIndex = i);
                                    setState(() => _selectedDateIndex = i);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.cyan.withValues(alpha: isDark ? 0.2 : 0.25)
                                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.cyan
                                            : (Theme.of(context).dividerTheme.color ??
                                                const Color(0xFF1C2A42)),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _dates[i],
                                        style: TextStyle(
                                          fontWeight:
                                              isSelected ? FontWeight.w800 : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? AppTheme.cyan : AppTheme.cyanLight)
                                              : Theme.of(context).colorScheme.onSurface,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 2. DURATION SELECTOR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '2. DURATION (HOURS)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppTheme.cyan,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                    color: _durationHours > 1
                                        ? AppTheme.cyan
                                        : Theme.of(context).colorScheme.outline,
                                    onPressed: _durationHours > 1
                                        ? () {
                                            setModalState(() => _durationHours--);
                                            setState(() => _durationHours--);
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$_durationHours ${_durationHours == 1 ? "Hour" : "Hours"}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    color: _durationHours < 12
                                        ? AppTheme.cyan
                                        : Theme.of(context).colorScheme.outline,
                                    onPressed: _durationHours < 12
                                        ? () {
                                            setModalState(() => _durationHours++);
                                            setState(() => _durationHours++);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 3. AVAILABLE TIME SLOTS
                          const Text(
                            '3. STARTING TIME SLOT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppTheme.cyan,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: _slots.map((s) {
                              final String time = s['time'];
                              final String status = s['status'];
                              final bool isReserved = status == 'Reserved';
                              final bool isSelected = time == _selectedSlot;

                              return InkWell(
                                onTap: isReserved
                                    ? null
                                    : () {
                                        setModalState(() => _selectedSlot = time);
                                        setState(() => _selectedSlot = time);
                                      },
                                child: Container(
                                  width: (MediaQuery.sizeOf(context).width - 64) / 3,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isReserved
                                        ? Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.4)
                                        : (isSelected
                                            ? AppTheme.cyan.withValues(alpha: isDark ? 0.2 : 0.25)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.cyan
                                          : (Theme.of(context).dividerTheme.color ??
                                              const Color(0xFF1C2A42)),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontWeight:
                                              isSelected ? FontWeight.w800 : FontWeight.w600,
                                          fontSize: 13,
                                          color: isReserved
                                              ? Theme.of(context).colorScheme.outline
                                              : (isSelected
                                                  ? (isDark
                                                      ? AppTheme.cyan
                                                      : AppTheme.cyanLight)
                                                  : Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isReserved
                                              ? AppTheme.error
                                              : (status == 'Filling Fast'
                                                  ? AppTheme.amber
                                                  : AppTheme.success),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // 4. PRICE BREAKDOWN SUMMARY
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context).dividerTheme.color ??
                                    const Color(0xFF1C2A42),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildPriceRow(
                                  'Slot Time',
                                  '$_selectedSlot (${_dates[_selectedDateIndex]})',
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow(
                                  'Parking Fee (₹$_hourlyRate × $_durationHours hrs)',
                                  '₹$_subtotal.00',
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow('Platform & Security Fee', '₹$_platformFee.00'),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '₹$_totalAmount.00',
                                      style: TextStyle(
                                        color: isDark ? AppTheme.cyan : AppTheme.cyanLight,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Request Booking Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _proceedToCheckout();
                    },
                    child: Text('Confirm Booking • ₹$_totalAmount.00'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Future<void> _proceedToCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _showLoginRequiredSheet();
    } else {
      context.push(
        '/booking-checkout',
        extra: {
          'parkingId': widget.parkingId,
          'parkingName': 'Metro Grand Parking Bay',
          'date': _dates[_selectedDateIndex],
          'slot': _selectedSlot,
          'duration': '$_durationHours Hours',
          'amount': '₹$_totalAmount.00',
        },
      );
    }
  }

  void _showLoginRequiredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppTheme.cyan, size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login to Reserve Spot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a free account or login with your mobile number to confirm your spot reservation.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                child: const Text('Login with Mobile Number'),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar with Parking Banner
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF142036),
                      Color(0xFF0A0F1E),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.local_parking_rounded,
                          size: 50,
                          color: AppTheme.cyan,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '● 4 BAYS AVAILABLE NOW',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Details content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metro Grand Parking Bay',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Theme.of(context).colorScheme.outline),
                                const SizedBox(width: 4),
                                Text(
                                  '0.3 km away • National Hub',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹50',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '/ hour',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Vehicle Compatibility Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: AppTheme.cyan, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Compatibility',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEn ? l.fitsYourVehicle : 'Fits standard passenger cars & SUVs ✓',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    isEn ? l.features : 'Features',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 14),

                  const _FeatureItem(
                    icon: Icons.roofing_rounded,
                    title: 'Covered Weather Protection',
                    subtitle: 'Full overhead canopy protects from sun & rain',
                  ),
                  const _FeatureItem(
                    icon: Icons.videocam_outlined,
                    title: '24/7 CCTV Surveillance',
                    subtitle: 'High-definition monitored cameras covering bays',
                  ),
                  const _FeatureItem(
                    icon: Icons.shield_outlined,
                    title: 'On-site Security Guard',
                    subtitle: 'Verified personnel present during all open hours',
                  ),
                  const _FeatureItem(
                    icon: Icons.ev_station_rounded,
                    title: 'EV Fast Charging Ready',
                    subtitle: 'Type-2 AC fast charger available at bay',
                  ),

                  const SizedBox(height: 22),

                  Text(
                    isEn ? l.providerInfo : 'Provider Info',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

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
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.business_rounded, color: AppTheme.cyan, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? l.verifiedOfficeBldg : 'Verified Commercial Partner',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isEn ? l.businessVerified : 'Business Verified • Safety Inspected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_rounded, color: AppTheme.cyan, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom CTA
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? const Color(0xFF1C2A42),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Rate',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '₹50 / hr',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: _openBookingSheet,
                  child: const Text('Select Time & Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.cyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
