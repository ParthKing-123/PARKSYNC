import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parksync/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String parkingId;
  const ParkingDetailScreen({super.key, required this.parkingId});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  // ── Booking Parameters ────────────────────────────────────────────────
  bool _isSaved = false;
  DateTime _selectedDate = DateTime.now();
  int _durationMinutes = 60; // Default 1 hour (minimum 30 minutes)
  String _selectedSlot = '10:00 AM';
  final TextEditingController _customMinutesCtrl = TextEditingController(text: '60');

  final List<Map<String, dynamic>> _slots = [
    {'time': '08:00 AM', 'hour': 8, 'minute': 0, 'status': 'Available'},
    {'time': '09:00 AM', 'hour': 9, 'minute': 0, 'status': 'Available'},
    {'time': '10:00 AM', 'hour': 10, 'minute': 0, 'status': 'Available'},
    {'time': '11:00 AM', 'hour': 11, 'minute': 0, 'status': 'Filling Fast'},
    {'time': '12:00 PM', 'hour': 12, 'minute': 0, 'status': 'Available'},
    {'time': '01:00 PM', 'hour': 13, 'minute': 0, 'status': 'Available'},
    {'time': '02:00 PM', 'hour': 14, 'minute': 0, 'status': 'Filling Fast'},
    {'time': '03:00 PM', 'hour': 15, 'minute': 0, 'status': 'Available'},
    {'time': '04:00 PM', 'hour': 16, 'minute': 0, 'status': 'Available'},
    {'time': '05:00 PM', 'hour': 17, 'minute': 0, 'status': 'Available'},
    {'time': '06:00 PM', 'hour': 18, 'minute': 0, 'status': 'Reserved'},
    {'time': '07:00 PM', 'hour': 19, 'minute': 0, 'status': 'Available'},
  ];

  final double _hourlyRate = 50.0;
  final double _platformFee = 10.0;

  double get _subtotal => (_durationMinutes / 60.0) * _hourlyRate;
  double get _totalAmount => _subtotal + _platformFee;

  @override
  void dispose() {
    _customMinutesCtrl.dispose();
    super.dispose();
  }

  // Format date helper: "Sat, 24 Oct 2026"
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today (${dt.day} ${months[dt.month - 1]})';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year && dt.month == tomorrow.month && dt.day == tomorrow.day) {
      return 'Tomorrow (${dt.day} ${months[dt.month - 1]})';
    }

    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // Calculate End Time string
  String _calculateEndTime() {
    final slot = _slots.firstWhere(
      (s) => s['time'] == _selectedSlot,
      orElse: () => _slots[2],
    );

    int startH = slot['hour'];
    int startM = slot['minute'];

    int totalStartMinutes = startH * 60 + startM;
    int totalEndMinutes = totalStartMinutes + _durationMinutes;

    int endH = (totalEndMinutes ~/ 60) % 24;
    int endM = totalEndMinutes % 60;

    String period = endH >= 12 ? 'PM' : 'AM';
    int displayH = endH % 12;
    if (displayH == 0) displayH = 12;

    String mStr = endM.toString().padLeft(2, '0');
    return '$displayH:$mStr $period';
  }

  // Formatted duration string: e.g. "47 mins" or "1 hr 30 mins"
  String _formatDuration(int mins) {
    if (mins < 60) {
      return '$mins mins';
    }
    final h = mins ~/ 60;
    final m = mins % 60;
    if (m == 0) {
      return '$h ${h == 1 ? "hour" : "hours"}';
    }
    return '$h hr $m mins';
  }

  // Pick any date from 1-year calendar
  Future<void> _pickDateFromCalendar(BuildContext context, StateSetter setModalState) async {
    final now = DateTime.now();
    final oneYearAhead = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: oneYearAhead,
      helpText: 'SELECT BOOKING DATE (UP TO 1 YEAR)',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setModalState(() => _selectedDate = picked);
      setState(() => _selectedDate = picked);
    }
  }

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
            final endTime = _calculateEndTime();

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.90,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Date & Custom Duration',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF143B33) : AppTheme.butterElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                          ),
                        ),
                        child: Text(
                          '₹${_hourlyRate.toInt()}/hr',
                          style: TextStyle(
                            color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ══════════════════════════════════════════════
                          // 1. CHOOSE DATE (1-YEAR CALENDAR)
                          // ══════════════════════════════════════════════
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1. DATE (1 YEAR BOOKINGS OPEN)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                                label: const Text('Open Calendar', style: TextStyle(fontSize: 12)),
                                onPressed: () => _pickDateFromCalendar(context, setModalState),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Selected Date Display Card
                          NeumorphicCard(
                            onTap: () => _pickDateFromCalendar(context, setModalState),
                            radius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available_rounded,
                                    color: AppTheme.forestGreen, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Tap to choose any date within 365 days',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.outline,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ══════════════════════════════════════════════
                          // 2. STARTING TIME SLOT
                          // ══════════════════════════════════════════════
                          Text(
                            '2. STARTING TIME SLOT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
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
                                      vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isReserved
                                        ? Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.4)
                                        : (isSelected
                                            ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? (isDark ? AppTheme.butter : AppTheme.forestGreen)
                                          : (Theme.of(context).dividerTheme.color ??
                                              (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
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
                                          fontSize: 12,
                                          color: isReserved
                                              ? Theme.of(context).colorScheme.outline
                                              : (isSelected
                                                  ? (isDark
                                                      ? AppTheme.forestGreenDark
                                                      : AppTheme.butter)
                                                  : Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isReserved
                                              ? AppTheme.error
                                              : (isSelected
                                                  ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
                                                  : (status == 'Filling Fast'
                                                      ? AppTheme.amber
                                                      : AppTheme.success)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // ══════════════════════════════════════════════
                          // 3. CUSTOM DURATION (MIN 30 MINS, ANY MINUTES)
                          // ══════════════════════════════════════════════
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '3. DURATION (MIN 30 MINS)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                ),
                              ),
                              Text(
                                _formatDuration(_durationMinutes),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Quick duration presets
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [30, 45, 60, 90, 120, 180].map((mins) {
                              final isSelected = _durationMinutes == mins;
                              final selectedBg = isDark ? AppTheme.butter : AppTheme.forestGreen;
                              final selectedFg = isDark ? AppTheme.forestGreenDark : AppTheme.butter;
                              final unselectedBg = isDark ? const Color(0xFF143B33) : AppTheme.butterElevated;
                              final unselectedFg = isDark ? AppTheme.butter : AppTheme.forestGreen;

                              return ChoiceChip(
                                label: Text(mins < 60 ? '$mins m' : '${mins / 60} h'),
                                selected: isSelected,
                                onSelected: (val) {
                                  setModalState(() {
                                    _durationMinutes = mins;
                                    _customMinutesCtrl.text = mins.toString();
                                  });
                                  setState(() {
                                    _durationMinutes = mins;
                                    _customMinutesCtrl.text = mins.toString();
                                  });
                                },
                                backgroundColor: unselectedBg,
                                selectedColor: selectedBg,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? selectedFg : unselectedFg,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // Interactive Custom Minute Stepper & Input
                          NeumorphicCard(
                            radius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 20, color: AppTheme.forestGreen),
                                const SizedBox(width: 10),
                                const Text(
                                  'Custom Duration:',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const Spacer(),

                                // [- 5m]
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                                  color: _durationMinutes > 30
                                      ? AppTheme.forestGreen
                                      : Theme.of(context).colorScheme.outline,
                                  onPressed: _durationMinutes > 30
                                      ? () {
                                          setModalState(() {
                                            _durationMinutes = (_durationMinutes - 5).clamp(30, 1440);
                                            _customMinutesCtrl.text = _durationMinutes.toString();
                                          });
                                          setState(() {});
                                        }
                                      : null,
                                ),

                                // Direct numeric input field for any minute (e.g. 40, 47, etc.)
                                SizedBox(
                                  width: 52,
                                  child: TextField(
                                    controller: _customMinutesCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val) ?? 30;
                                      final valid = parsed < 30 ? 30 : parsed;
                                      setModalState(() => _durationMinutes = valid);
                                      setState(() => _durationMinutes = valid);
                                    },
                                  ),
                                ),
                                const Text('mins', style: TextStyle(fontSize: 12, color: Colors.grey)),

                                // [+ 5m]
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                  color: AppTheme.forestGreen,
                                  onPressed: () {
                                    setModalState(() {
                                      _durationMinutes = (_durationMinutes + 5).clamp(30, 1440);
                                      _customMinutesCtrl.text = _durationMinutes.toString();
                                    });
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ══════════════════════════════════════════════
                          // 4. LIVE PRICE & SESSION BREAKDOWN
                          // ══════════════════════════════════════════════
                          NeumorphicCard(
                            radius: 14,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildPriceRow(
                                  'Timing Window',
                                  '$_selectedSlot to $endTime',
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow(
                                  'Selected Duration',
                                  '$_durationMinutes Minutes (${_formatDuration(_durationMinutes)})',
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow(
                                  'Parking Fee (Pro-rata at ₹${_hourlyRate.toInt()}/hr)',
                                  '₹${_subtotal.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow('Platform & Security Fee', '₹${_platformFee.toStringAsFixed(2)}'),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Estimated Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '₹${_totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
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

                  // Send Request to Host CTA Button
                  NeumorphicButton(
                    height: 48,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _proceedToCheckout();
                    },
                    child: Text(
                      'Request Spot from Host • ₹${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
          'date': _formatDate(_selectedDate),
          'slot': '$_selectedSlot to ${_calculateEndTime()}',
          'duration': '$_durationMinutes Mins (${_formatDuration(_durationMinutes)})',
          'amount': '₹${_totalAmount.toStringAsFixed(2)}',
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                  ),
                ),
                child: Icon(Icons.lock_outline_rounded,
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen, size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login to Request Spot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in with your mobile number to submit this booking request to the host.',
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SweetBookmarkButton(
                  isSaved: _isSaved,
                  itemName: 'Parking Spot',
                  onToggle: (saved) => setState(() => _isSaved = saved),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0C3029),
                      Color(0xFF031411),
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
                          color: AppTheme.butter.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.butter.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_parking_rounded,
                          size: 50,
                          color: AppTheme.butter,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.45)),
                        ),
                        child: const Text(
                          '● 4 BAYS AVAILABLE NOW',
                          style: TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
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
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return Padding(
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
                                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: isDark ? const Color(0xFFD6EAE5) : Theme.of(context).colorScheme.outline),
                                    const SizedBox(width: 4),
                                    Text(
                                      '0.3 km away • National Hub',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF143B33) : AppTheme.butterElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                                width: 1.0,
                              ),
                              boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 2.5, blur: 6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${_hourlyRate.toInt()}',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  '/ hour',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textMutedLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Vehicle Compatibility Banner
                      NeumorphicCard(
                        radius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                                ),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vehicle Compatibility',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textMutedLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isEn ? l.fitsYourVehicle : 'Fits standard passenger cars & SUVs ✓',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Host & Owner Information',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 12, color: AppTheme.success),
                            SizedBox(width: 4),
                            Text(
                              'Verified by Platform ✓',
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
                  const SizedBox(height: 12),

                  NeumorphicCard(
                    padding: const EdgeInsets.all(18),
                    radius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.15),
                              child: const Icon(Icons.person_rounded, size: 30, color: AppTheme.forestGreen),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rajesh Sharma',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Commercial Space Manager • Metro Infra Group',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Color(0xFFFFB800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Host Gmail & Contact details
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: AppTheme.forestGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'rajesh.sharma.parking@gmail.com',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                            const Text(
                              'Verified Gmail ✓',
                              style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AppTheme.forestGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '+91 98230 ••••• (Verified Phone)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: AppTheme.success),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Physical Site Inspected & Approved by ParkSync',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 110),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),

      // Fixed Bottom CTA
      bottomSheet: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerTheme.color ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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
                        'Starting from',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD6EAE5) : Theme.of(context).colorScheme.outline,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${_hourlyRate.toInt()} / hr',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: NeumorphicButton(
                      height: 50,
                      isPrimary: true,
                      onPressed: _openBookingSheet,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Select Time & Book', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(12),
        radius: 14,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF23695B) : AppTheme.borderLight,
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: isDark ? AppTheme.butter : AppTheme.forestGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
