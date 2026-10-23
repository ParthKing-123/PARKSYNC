import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_client.dart';
import '../../../../core/user_state_service.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../../shared/widgets/sweet_popup.dart';

class AddVehicleScreen extends StatefulWidget {
  final bool isFromOnboarding;
  const AddVehicleScreen({super.key, this.isFromOnboarding = true});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String? _selectedMake = 'Hyundai';
  String? _selectedModelName = 'Creta';
  String? _selectedModelId = 'vm_h1';
  String _selectedYear = '2023';
  String _selectedVariant = 'Petrol (Standard)';
  String _selectedType = 'Compact SUV';
  final _regController = TextEditingController(text: 'MH 12 AB ');
  bool _isLoading = false;

  // Search filter query
  String _searchQuery = '';

  // Master catalog of vehicles (guaranteed offline availability + backend sync)
  static final List<Map<String, dynamic>> _defaultVehicleModels = [
    // Hyundai
    {'id': 'vm_h1', 'make': 'Hyundai', 'model': 'Creta', 'type': 'Compact SUV', 'year': '2020-2024'},
    {'id': 'vm_h2', 'make': 'Hyundai', 'model': 'Venue', 'type': 'Subcompact SUV', 'year': '2021-2024'},
    {'id': 'vm_h3', 'make': 'Hyundai', 'model': 'i20', 'type': 'Hatchback', 'year': '2019-2024'},
    {'id': 'vm_h4', 'make': 'Hyundai', 'model': 'Verna', 'type': 'Sedan', 'year': '2020-2024'},
    {'id': 'vm_h5', 'make': 'Hyundai', 'model': 'Tucson', 'type': 'Full SUV', 'year': '2022-2024'},
    // Tata Motors
    {'id': 'vm_t1', 'make': 'Tata Motors', 'model': 'Nexon', 'type': 'Compact SUV', 'year': '2020-2024'},
    {'id': 'vm_t2', 'make': 'Tata Motors', 'model': 'Punch', 'type': 'Micro SUV', 'year': '2021-2024'},
    {'id': 'vm_t3', 'make': 'Tata Motors', 'model': 'Harrier', 'type': 'Mid SUV', 'year': '2020-2024'},
    {'id': 'vm_t4', 'make': 'Tata Motors', 'model': 'Safari', 'type': 'Full SUV', 'year': '2021-2024'},
    {'id': 'vm_t5', 'make': 'Tata Motors', 'model': 'Altroz', 'type': 'Hatchback', 'year': '2020-2024'},
    {'id': 'vm_t6', 'make': 'Tata Motors', 'model': 'Nexon EV', 'type': 'Electric SUV', 'year': '2022-2024'},
    // Maruti Suzuki
    {'id': 'vm_m1', 'make': 'Maruti Suzuki', 'model': 'Brezza', 'type': 'Compact SUV', 'year': '2020-2024'},
    {'id': 'vm_m2', 'make': 'Maruti Suzuki', 'model': 'Swift', 'type': 'Hatchback', 'year': '2018-2024'},
    {'id': 'vm_m3', 'make': 'Maruti Suzuki', 'model': 'Baleno', 'type': 'Hatchback', 'year': '2019-2024'},
    {'id': 'vm_m4', 'make': 'Maruti Suzuki', 'model': 'Grand Vitara', 'type': 'SUV', 'year': '2022-2024'},
    {'id': 'vm_m5', 'make': 'Maruti Suzuki', 'model': 'Ertiga', 'type': 'MUV', 'year': '2019-2024'},
    // Mahindra
    {'id': 'vm_mh1', 'make': 'Mahindra', 'model': 'Thar', 'type': 'Off-road 4x4', 'year': '2020-2024'},
    {'id': 'vm_mh2', 'make': 'Mahindra', 'model': 'XUV700', 'type': 'Full SUV', 'year': '2021-2024'},
    {'id': 'vm_mh3', 'make': 'Mahindra', 'model': 'Scorpio-N', 'type': 'Full SUV', 'year': '2022-2024'},
    {'id': 'vm_mh4', 'make': 'Mahindra', 'model': 'XUV300', 'type': 'Compact SUV', 'year': '2020-2024'},
    // Kia
    {'id': 'vm_k1', 'make': 'Kia', 'model': 'Seltos', 'type': 'Compact SUV', 'year': '2020-2024'},
    {'id': 'vm_k2', 'make': 'Kia', 'model': 'Sonet', 'type': 'Subcompact SUV', 'year': '2021-2024'},
    {'id': 'vm_k3', 'make': 'Kia', 'model': 'Carens', 'type': 'MUV', 'year': '2022-2024'},
    // Toyota
    {'id': 'vm_ty1', 'make': 'Toyota', 'model': 'Fortuner', 'type': 'Full SUV', 'year': '2020-2024'},
    {'id': 'vm_ty2', 'make': 'Toyota', 'model': 'Innova HyCross', 'type': 'MUV', 'year': '2022-2024'},
    {'id': 'vm_ty3', 'make': 'Toyota', 'model': 'Urban Cruiser', 'type': 'Compact SUV', 'year': '2021-2024'},
    // Honda
    {'id': 'vm_hd1', 'make': 'Honda', 'model': 'City', 'type': 'Sedan', 'year': '2020-2024'},
    {'id': 'vm_hd2', 'make': 'Honda', 'model': 'Elevate', 'type': 'Compact SUV', 'year': '2023-2024'},
    {'id': 'vm_hd3', 'make': 'Honda', 'model': 'Amaze', 'type': 'Sedan', 'year': '2021-2024'},
    // BMW
    {'id': 'vm_bm1', 'make': 'BMW', 'model': '3 Series', 'type': 'Executive Sedan', 'year': '2021-2024'},
    {'id': 'vm_bm2', 'make': 'BMW', 'model': 'X1', 'type': 'Compact Luxury SUV', 'year': '2022-2024'},
    // Mercedes-Benz
    {'id': 'vm_mb1', 'make': 'Mercedes-Benz', 'model': 'C-Class', 'type': 'Luxury Sedan', 'year': '2021-2024'},
    {'id': 'vm_mb2', 'make': 'Mercedes-Benz', 'model': 'GLA', 'type': 'Compact Luxury SUV', 'year': '2022-2024'},
  ];

  final List<String> _years = ['2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017 or older'];
  final List<String> _variants = [
    'Petrol (Standard)',
    'Diesel (Turbo)',
    'Electric (EV)',
    'CNG / Hybrid',
    'Automatic Transmission',
    'Manual Transmission',
  ];

  List<dynamic> _vehicleModels = [];
  List<String> _makes = [];

  @override
  void initState() {
    super.initState();
    _initCatalog();
    _fetchVehicleModels();
  }

  @override
  void dispose() {
    _regController.dispose();
    super.dispose();
  }

  void _initCatalog() {
    _vehicleModels = List.from(_defaultVehicleModels);
    final makesSet = <String>{};
    for (var m in _vehicleModels) {
      makesSet.add(m['make']);
    }
    _makes = makesSet.toList()..sort();
  }

  void _fetchVehicleModels() async {
    try {
      final response = await ApiClient().dio.get('/vehicles/models');
      if (response.data is List && (response.data as List).isNotEmpty) {
        final serverModels = response.data as List<dynamic>;
        if (mounted) {
          setState(() {
            _vehicleModels = serverModels;
            final makesSet = <String>{};
            for (var m in serverModels) {
              if (m['make'] != null) makesSet.add(m['make'].toString());
            }
            _makes = makesSet.toList()..sort();
          });
        }
      }
    } catch (_) {
      // Offline fallback is already active
    }
  }

  void _showMakeSearchSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _makes.where((m) => m.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Vehicle Manufacturer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  NeumorphicCard(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: TextField(
                      autofocus: false,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search make (e.g. Tata, Hyundai)...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (val) {
                        setSheetState(() => _searchQuery = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final make = filtered[i];
                        final isSel = make == _selectedMake;
                        return ListTile(
                          title: Text(
                            make,
                            style: TextStyle(
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel
                                  ? (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSel
                              ? Icon(Icons.check_circle_rounded,
                                  color: isDark ? AppTheme.accentGold : AppTheme.forestGreen, size: 20)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedMake = make;
                              final available = _vehicleModels.where((m) => m['make'] == make).toList();
                              if (available.isNotEmpty) {
                                _selectedModelName = available.first['model'];
                                _selectedModelId = available.first['id'];
                                _selectedType = available.first['type'] ?? 'Compact SUV';
                              }
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
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

  void _saveVehicle() async {
    final reg = _regController.text.trim();
    if (_selectedMake == null || _selectedModelName == null || reg.isEmpty || reg.length < 5) {
      SweetPopup.show(
        context,
        title: 'Registration Required',
        message: 'Please enter a valid vehicle license plate number (e.g. MH 12 AB 1234).',
        icon: Icons.directions_car_outlined,
        iconColor: AppTheme.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final newVehicle = UserVehicle(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      make: _selectedMake!,
      model: _selectedModelName!,
      year: _selectedYear,
      variant: _selectedVariant,
      plateNumber: reg.toUpperCase(),
      type: _selectedType,
      isDefault: true,
    );

    // 1. Save to central UserStateService
    await UserStateService.instance.addVehicle(newVehicle);

    // 2. Persist in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_vehicle_name', '${newVehicle.make} ${newVehicle.model}');
    await prefs.setString('selected_vehicle_reg', newVehicle.plateNumber);

    // 3. Sync with backend API
    try {
      await ApiClient().dio.post('/vehicles', data: {
        'vehicleModelId': _selectedModelId,
        'registrationNumber': newVehicle.plateNumber,
        'year': _selectedYear,
        'variant': _selectedVariant,
        'isPrimary': true,
      });
    } catch (_) {
      // Offline fallback resilient
    }

    if (mounted) {
      setState(() => _isLoading = false);
      SweetPopup.show(
        context,
        title: 'Vehicle Added to Garage!',
        message: '${newVehicle.make} ${newVehicle.model} (${newVehicle.plateNumber}) active.',
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        context.go('/guest-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableModels = _vehicleModels.where((m) => m['make'] == _selectedMake).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Vehicle Setup',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/guest-home');
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Skip vehicle setup and explore
              context.go('/guest-home');
            },
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dimension matching explanation banner
              NeumorphicCard(
                padding: const EdgeInsets.all(14),
                radius: 16,
                color: isDark ? null : AppTheme.butter,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF143B33) : AppTheme.forestGreen.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.straighten_rounded,
                        size: 22,
                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Dimension Compatibility',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'We match parking bay height, length, and ramp clearance to protect your vehicle.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFD6EAE5) : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 1. Searchable Vehicle Make
              Text(
                'Vehicle Manufacturer / Make *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              NeumorphicCard(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onTap: _showMakeSearchSheet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car_rounded,
                            size: 20, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
                        const SizedBox(width: 12),
                        Text(
                          _selectedMake ?? 'Select Make',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                            )),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 13, color: isDark ? AppTheme.accentGold : AppTheme.forestGreen),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Searchable Model
              Text(
                'Model Name *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              NeumorphicCard(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: availableModels.any((m) => m['model'] == _selectedModelName)
                        ? _selectedModelName
                        : (availableModels.isNotEmpty ? availableModels.first['model'] : null),
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen),
                    dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                    hint: const Text('Select Model'),
                    items: availableModels.map<DropdownMenuItem<String>>((model) {
                      return DropdownMenuItem<String>(
                        value: model['model'],
                        child: Row(
                          children: [
                            Text(
                              model['model'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF143B33) : const Color(0xFFEFE8D0)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                model['type'] ?? 'Car',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = availableModels.firstWhere((m) => m['model'] == val);
                        setState(() {
                          _selectedModelName = val;
                          _selectedModelId = found['id'];
                          _selectedType = found['type'] ?? 'Compact SUV';
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Manufacturing Year & Variant Row
              Row(
                children: [
                  // Year Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        NeumorphicCard(
                          radius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedYear,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen),
                              dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                              items: _years.map((y) {
                                return DropdownMenuItem<String>(
                                  value: y,
                                  child: Text(y, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedYear = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Fuel / Variant
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel / Variant',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        NeumorphicCard(
                          radius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedVariant,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen),
                              dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                              items: _variants.map((v) {
                                return DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(
                                    v.split(' ').first,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedVariant = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 4. Registration Plate Number
              Text(
                'Vehicle Registration Number (RC) *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              NeumorphicCard(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _regController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'MH 12 AB 1234',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Text(
                        '🇮🇳 IND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Action
              NeumorphicButton(
                height: 52,
                onPressed: _isLoading ? null : _saveVehicle,
                child: _isLoading
                    ? const CarLoadingIndicator(size: 28)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.isFromOnboarding ? 'Save & Start Exploring' : 'Save Vehicle',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/guest-home'),
                  child: Text(
                    'I\'ll add this later (Skip to Map)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
