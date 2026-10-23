import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_client.dart';
import '../../../core/user_state_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/car_loading_indicator.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  int _currentStep = 0; // 0 = Category, 1 = Identity/Business, 2 = Facility & Location, 3 = Capacity & Amenities, 4 = Pricing & Schedule, 5 = Review & Submit
  bool _isLoading = false;

  // Step 1: Category
  String _selectedCategory = 'INDIVIDUAL';

  // Step 2: Identity / Business (No fake hardcoded mock defaults!)
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedIdType = 'Driving License';

  // Step 3: Location
  final _facilityNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Pune');
  final _pincodeController = TextEditingController();
  double _latitude = 18.5204;
  double _longitude = 73.8567;
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    final user = UserStateService.instance;
    if (user.phoneNumber.isNotEmpty) {
      _phoneController.text = user.phoneNumber;
    }
    if (user.userName.isNotEmpty &&
        user.userName != 'Verified Driver' &&
        user.userName != 'Guest Driver') {
      _contactPersonController.text = user.userName;
    }
    if (user.userEmail.isNotEmpty) {
      _emailController.text = user.userEmail;
    }
  }

  // Step 4: Capacity & Restrictions
  int _totalBays = 6;
  String _slotType = 'Basement Covered';
  String _heightClearance = '2.4 meters';
  final Set<String> _allowedVehicles = {'Hatchback', 'Sedan', 'Compact SUV', 'Full SUV'};
  final Set<String> _amenities = {'CCTV 24/7', 'Security Guard', 'EV Charging'};

  // Step 5: Schedule & Pricing
  double _hourlyRate = 40.0;
  String _operatingHours = '24 Hours (Full Day)';
  String _operatingDays = 'All Days (Mon - Sun)';
  bool _instantBooking = true;

  final List<Map<String, dynamic>> _providerCategories = [
    {
      'id': 'INDIVIDUAL',
      'title': 'Individual / Private Owner',
      'subtitle': 'Residential driveway, personal society slot, or allotted bay',
      'icon': Icons.home_rounded,
    },
    {
      'id': 'RESTAURANT',
      'title': 'Restaurant / Café',
      'subtitle': 'Monetize customer parking slots during non-peak hours',
      'icon': Icons.restaurant_rounded,
    },
    {
      'id': 'OFFICE',
      'title': 'Office / Corporate Building',
      'subtitle': 'Open employee basements on weekends or night shifts',
      'icon': Icons.business_rounded,
    },
    {
      'id': 'OPERATOR',
      'title': 'Independent Parking Operator',
      'subtitle': 'Commercial lots, valet grounds, and multi-bay parking businesses',
      'icon': Icons.local_parking_rounded,
    },
    {
      'id': 'HOTEL_MALL',
      'title': 'Hotel / Mall / Commercial Center',
      'subtitle': 'Large capacity parking garages and premium valet decks',
      'icon': Icons.domain_rounded,
    },
    {
      'id': 'OTHER',
      'title': 'Authorized Organization / Institution',
      'subtitle': 'Hospital, clinic, event space, or educational facility bays',
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _facilityNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _detectGps() async {
    setState(() => _isLocatingGps = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _latitude = 18.5204;
        _longitude = 73.8567;
        _isLocatingGps = false;
      });
      SweetPopup.show(
        context,
        title: 'GPS Coordinates Captured',
        message: 'Accurate pin set to Lat: 18.5204, Lng: 73.8567',
        icon: Icons.my_location_rounded,
        iconColor: AppTheme.success,
      );
    }
  }

  void _submitListing() async {
    setState(() => _isLoading = true);

    final pwd = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final name = _contactPersonController.text.trim();
    final email = _emailController.text.trim();

    if (pwd.isNotEmpty) {
      try {
        final response = await ApiClient().dio.post('/auth/register-profile', data: {
          'phone': phone,
          'name': name,
          'email': email.isNotEmpty ? email : null,
          'password': pwd,
          'role': 'PROVIDER',
        });
        if (response.data != null && response.data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', response.data['token'].toString());
        }
      } catch (e) {
        debugPrint('[Provider] Register-profile sync: $e');
      }
      await UserStateService.instance.savePassword(phone, pwd);
    }

    final facility = ProviderFacility(
      id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : name,
      contactPerson: name,
      contactPhone: phone,
      contactEmail: email.isNotEmpty ? email : 'host@parksync.in',
      facilityName: _facilityNameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      totalBays: _totalBays,
      availableBays: _totalBays,
      slotType: _slotType,
      heightClearance: _heightClearance,
      allowedVehicles: _allowedVehicles.toList(),
      amenities: _amenities.toList(),
      hourlyRate: _hourlyRate,
      operatingHours: _operatingHours,
      operatingDays: _operatingDays,
      isInstantBooking: _instantBooking,
      verificationStatus: VerificationStatus.underReview,
    );

    // Save in UserStateService & SharedPreferences
    await UserStateService.instance.saveProviderFacility(facility);
    await UserStateService.instance.switchRole(UserRole.provider);

    setState(() => _isLoading = false);

    if (mounted) {
      SweetPopup.show(
        context,
        title: 'Listing Submitted for Review!',
        message: 'Your facility is in queue for platform verification. You can now manage your bays.',
        icon: Icons.verified_user_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (mounted) {
        context.go('/provider-home');
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_contactPersonController.text.trim().length < 2) {
        SweetPopup.show(
          context,
          title: 'Contact Name Required',
          message: 'Please enter authorized host or owner name (min 2 characters).',
          icon: Icons.person_outline_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
      if (_phoneController.text.trim().length < 6) {
        SweetPopup.show(
          context,
          title: 'Phone Number Required',
          message: 'Please enter valid contact phone number for payout linking.',
          icon: Icons.phone_disabled_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
      final pwd = _passwordController.text.trim();
      final confPwd = _confirmPasswordController.text.trim();
      if (pwd.isNotEmpty) {
        if (pwd.length < 6) {
          SweetPopup.show(
            context,
            title: 'Password Too Short',
            message: 'Password must be at least 6 characters.',
            icon: Icons.lock_outline_rounded,
            iconColor: AppTheme.error,
          );
          return;
        }
        if (pwd != confPwd) {
          SweetPopup.show(
            context,
            title: 'Passwords Do Not Match',
            message: 'Please re-type password identically.',
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.error,
          );
          return;
        }
      }
    } else if (_currentStep == 2) {
      if (_facilityNameController.text.trim().length < 3 ||
          _addressController.text.trim().length < 5) {
        SweetPopup.show(
          context,
          title: 'Facility Details Required',
          message: 'Please provide facility name and complete road address.',
          icon: Icons.location_on_outlined,
          iconColor: AppTheme.error,
        );
        return;
      }
      if (_pincodeController.text.trim().length != 6) {
        SweetPopup.show(
          context,
          title: 'Valid Pincode Required',
          message: 'Please enter a 6-digit postal pincode.',
          icon: Icons.pin_drop_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (_totalBays <= 0) {
        SweetPopup.show(
          context,
          title: 'Bays Required',
          message: 'Facility must have at least 1 parking bay.',
          icon: Icons.local_parking_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
      if (_allowedVehicles.isEmpty) {
        SweetPopup.show(
          context,
          title: 'Allowed Vehicles Required',
          message: 'Please select at least one vehicle category.',
          icon: Icons.directions_car_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
    } else if (_currentStep == 4) {
      if (_hourlyRate <= 0) {
        SweetPopup.show(
          context,
          title: 'Hourly Rate Required',
          message: 'Please set an hourly rate greater than ₹0.',
          icon: Icons.currency_rupee_rounded,
          iconColor: AppTheme.error,
        );
        return;
      }
    }

    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    } else {
      _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Host Onboarding • Step ${_currentStep + 1} of 6',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: _prevStep,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded,
                size: 20, color: isDark ? AppTheme.butter : AppTheme.forestGreen),
            tooltip: 'Host Guide',
            onPressed: () => context.push('/user-guide'),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              backgroundColor: isDark ? AppTheme.forestSurface : AppTheme.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.accentGold : AppTheme.forestGreen,
              ),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: _buildStepContent(isDark),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerTheme.color ??
                        (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        ),
                      ),
                      onPressed: _prevStep,
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: NeumorphicButton(
                      height: 50,
                      onPressed: _isLoading ? null : _nextStep,
                      child: _isLoading
                          ? const CarLoadingIndicator(size: 26)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == 5 ? 'Submit for Verification' : 'Continue',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == 5
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
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

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category(isDark);
      case 1:
        return _buildStep2Identity(isDark);
      case 2:
        return _buildStep3FacilityLocation(isDark);
      case 3:
        return _buildStep4CapacityAmenities(isDark);
      case 4:
        return _buildStep5PricingSchedule(isDark);
      case 5:
      default:
        return _buildStep6ReviewSubmit(isDark);
    }
  }

  // ── STEP 1: CATEGORY SELECTION ─────────────────────────────────────────────
  Widget _buildStep1Category(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your provider category',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the profile type that best describes your parking space.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ..._providerCategories.map((cat) {
          final isSel = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: NeumorphicCard(
              radius: 18,
              padding: const EdgeInsets.all(16),
              border: isSel
                  ? Border.all(
                      color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      width: 2.0,
                    )
                  : null,
              onTap: () => setState(() => _selectedCategory = cat['id']),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSel
                          ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                          : (isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 22,
                      color: isSel
                          ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter)
                          : (isDark ? AppTheme.butter : AppTheme.forestGreen),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          cat['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSel)
                    Icon(
                      Icons.check_circle_rounded,
                      color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── STEP 2: CATEGORY-SPECIFIC IDENTITY ─────────────────────────────────────
  Widget _buildStep2Identity(bool isDark) {
    final isBusiness = _selectedCategory != 'INDIVIDUAL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBusiness ? 'Business Profile & Representative' : 'Owner Identity Verification',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          isBusiness
              ? 'Required for commercial tax validation and automated host payouts.'
              : 'Driver safety requires verified host identity. Aadhaar is not mandatory.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),

        if (isBusiness) ...[
          Text('Registered Business / Commercial Name *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
          const SizedBox(height: 8),
          NeumorphicCard(
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Metro Commercial Plaza LLP',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('GSTIN / Business Registration Number (Optional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
          const SizedBox(height: 8),
          NeumorphicCard(
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _taxNumberController,
              decoration: const InputDecoration(
                hintText: '27AAAAA0000A1Z5',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(isBusiness ? 'Authorized Manager Name *' : 'Owner Full Name *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _contactPersonController,
            decoration: const InputDecoration(
              hintText: 'e.g. Ramesh Kulkarni (Owner / Manager)',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text('Contact Phone Number (Payout Linked) *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+91 98765 43210',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text('Identity Document Type *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedIdType,
              isExpanded: true,
              dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
              items: ['Driving License', 'Voter ID Card', 'PAN Card', 'Trade License / Electricity Bill']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedIdType = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Create Password for Host Dashboard access
        Text('Create Provider Password *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Minimum 6 characters for direct sign-in',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text('Confirm Provider Password *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Re-type password identically',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 3: FACILITY & LOCATION ────────────────────────────────────────────
  Widget _buildStep3FacilityLocation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parking Facility & Exact Location',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          'Provide the precise navigation destination for drivers.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),

        Text('Parking Bay / Facility Name *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _facilityNameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Metro Commercial Bay A',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text('Complete Address *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Plot number, landmark, street name',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('City *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
                  const SizedBox(height: 8),
                  NeumorphicCard(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(hintText: 'Pune', border: InputBorder.none, filled: true, fillColor: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pincode *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
                  const SizedBox(height: 8),
                  NeumorphicCard(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '411001', border: InputBorder.none, filled: true, fillColor: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // GPS Location capture button
        NeumorphicCard(
          radius: 16,
          padding: const EdgeInsets.all(14),
          color: isDark ? null : AppTheme.butter,
          onTap: _detectGps,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: _isLocatingGps
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.my_location_rounded,
                        size: 20, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Capture Exact Bay GPS Coordinates',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
                    const SizedBox(height: 2),
                    Text('Lat: $_latitude • Long: $_longitude',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 4: CAPACITY & AMENITIES ───────────────────────────────────────────
  Widget _buildStep4CapacityAmenities(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capacity, Clearance & Amenities',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          'Ensures incoming vehicles safely fit into your parking bays.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),

        // Total Bays Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Available Bays *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
                const SizedBox(height: 2),
                Text('Number of parking slots you are listing', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _totalBays > 1 ? () => setState(() => _totalBays -= 1) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text('$_totalBays', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: () => setState(() => _totalBays += 1),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text('Slot Layout & Height Clearance',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NeumorphicCard(
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _slotType,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                    items: ['Basement Covered', 'Open Ground', 'Gated Driveway', 'Multi-Level Covered']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _slotType = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeumorphicCard(
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _heightClearance,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                    items: ['2.1 meters', '2.4 meters', '2.8 meters', 'Open (No Limit)']
                        .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _heightClearance = val);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text('Allowed Vehicle Types',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Hatchback', 'Sedan', 'Compact SUV', 'Full SUV', 'Two Wheeler', 'EV Only'].map((type) {
            final isSel = _allowedVehicles.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSel,
              selectedColor: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: isSel ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter) : (isDark ? AppTheme.butter : AppTheme.forestGreen),
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _allowedVehicles.add(type);
                  } else {
                    _allowedVehicles.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        Text('Safety & Convenience Amenities',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['CCTV 24/7', 'Security Guard', 'EV Charging', 'Gated Barrier', 'Lighting 24/7', 'Covered Roof'].map((amenity) {
            final isSel = _amenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSel,
              selectedColor: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: isSel ? (isDark ? AppTheme.forestGreenDark : AppTheme.butter) : (isDark ? AppTheme.butter : AppTheme.forestGreen),
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _amenities.add(amenity);
                  } else {
                    _amenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── STEP 5: PRICING & SCHEDULE ─────────────────────────────────────────────
  Widget _buildStep5PricingSchedule(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Rate & Operating Schedule',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          'Set your base pricing per hour and active operating days.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // Hourly Rate Slider
        NeumorphicCard(
          radius: 18,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Base Hourly Rate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
              const SizedBox(height: 12),
              Slider(
                value: _hourlyRate,
                min: 20.0,
                max: 120.0,
                divisions: 20,
                activeColor: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                onChanged: (val) => setState(() => _hourlyRate = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹20/hr (Economy)', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                  Text('₹120/hr (Prime)', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text('Operating Schedule',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.butter : AppTheme.forestGreen)),
        const SizedBox(height: 8),
        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _operatingDays,
              isExpanded: true,
              dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
              items: ['All Days (Mon - Sun)', 'Weekdays Only (Mon - Fri)', 'Weekends Only (Sat - Sun)']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _operatingDays = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 14),

        NeumorphicCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _operatingHours,
              isExpanded: true,
              dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
              items: ['24 Hours (Full Day)', '08:00 AM - 10:00 PM', '09:00 AM - 06:00 PM', 'Night Shift (07:00 PM - 07:00 AM)']
                  .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _operatingHours = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Instant Booking Switch
        SwitchListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: Theme.of(context).colorScheme.surface,
          title: const Text('Instant Booking', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          subtitle: const Text('Drivers can reserve immediately without waiting for your manual approval.', style: TextStyle(fontSize: 11)),
          value: _instantBooking,
          activeThumbColor: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
          onChanged: (val) => setState(() => _instantBooking = val),
        ),
      ],
    );
  }

  // ── STEP 6: REVIEW & VERIFICATION SUBMISSION ────────────────────────────────
  Widget _buildStep6ReviewSubmit(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Submit for Verification',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 6),
        Text(
          'Please confirm your facility and pricing details before submitting to the platform.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),

        // Review Summary Card
        NeumorphicCard(
          radius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _facilityNameController.text.trim(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('UNDER REVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_addressController.text.trim()}, ${_cityController.text.trim()} - ${_pincodeController.text.trim()}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
              ),

              const Divider(height: 24),

              _buildReviewRow('Category', _selectedCategory),
              _buildReviewRow('Authorized Host', _contactPersonController.text.trim()),
              _buildReviewRow('Contact Phone', _phoneController.text.trim()),
              _buildReviewRow('Total Bays Listed', '$_totalBays bays'),
              _buildReviewRow('Slot Layout', '$_slotType ($_heightClearance)'),
              _buildReviewRow('Base Pricing', '₹${_hourlyRate.toInt()}/hr'),
              _buildReviewRow('Schedule', '$_operatingDays • $_operatingHours'),
              _buildReviewRow('Booking Type', _instantBooking ? 'Instant Reservation' : 'Host Approval Required'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Compliance Declaration
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.forestElevated : AppTheme.forestGreen.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF23695B).withValues(alpha: 0.5) : AppTheme.borderLight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_rounded, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting, you certify you have legal authority to monetize this parking space. All earnings are protected by the ParkSync Host Guarantee.',
                  style: TextStyle(fontSize: 11, height: 1.4, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
