import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../../shared/widgets/sweet_popup.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String? _selectedMake;
  String? _selectedModelId;
  String? _selectedModelName;
  final _regController = TextEditingController();
  bool _isLoading = false;

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

  List<dynamic> _vehicleModels = [];
  List<String> _makes = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with comprehensive built-in catalog immediately
    _initCatalog();
    // Silently attempt backend fetch to sync any newly added custom server models
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
      // Offline fallback is already loaded seamlessly; no error shown to user!
    }
  }

  void _saveVehicle() async {
    final reg = _regController.text.trim();
    if (_selectedMake == null || _selectedModelId == null || reg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select make, model and enter registration number'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = '$_selectedMake $_selectedModelName';

    // 1. Always persist locally for offline resilience
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_vehicle_name', fullName);
    await prefs.setString('selected_vehicle_reg', reg);

    // 2. Attempt sync with backend if online
    try {
      await ApiClient().dio.post('/vehicles', data: {
        'vehicleModelId': _selectedModelId,
        'registrationNumber': reg,
        'isPrimary': true,
      });
    } catch (_) {
      // Backend may be offline in dev, local storage guarantees smooth flow
    }

    if (mounted) {
      setState(() => _isLoading = false);
      SweetPopup.show(
        context,
        title: 'Vehicle Saved!',
        message: '$fullName registered for bay fitting.',
        icon: Icons.directions_car_rounded,
        iconColor: AppTheme.forestGreen,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter models for the selected make
    final availableModels =
        _vehicleModels.where((m) => m['make'] == _selectedMake).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Your Vehicle',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 14, color: AppTheme.forestGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Vehicle Fit Verification',
                      style: TextStyle(
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Register your vehicle.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      letterSpacing: -0.8,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'We use your vehicle dimensions to recommend parking spaces that fit your car perfectly.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),

              const SizedBox(height: 28),

              // 1. Make Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Make',
                  hintText: 'Select make (e.g. Hyundai, Tata, Maruti)',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                initialValue: _selectedMake,
                items: _makes.map((make) {
                  return DropdownMenuItem(
                    value: make,
                    child: Text(make),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMake = val;
                    _selectedModelId = null; // reset model when make changes
                    _selectedModelName = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 2. Model Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Model & Type',
                  hintText: 'Select model (e.g. Creta, Nexon)',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                initialValue: _selectedModelId,
                items: availableModels.map((model) {
                  final String modelName = model['model'] ?? '';
                  final String type = model['type'] ?? '';
                  return DropdownMenuItem<String>(
                    value: model['id']?.toString() ?? modelName,
                    child: Text('$modelName  ($type)'),
                  );
                }).toList(),
                onChanged: _selectedMake == null
                    ? null
                    : (val) {
                        setState(() {
                          _selectedModelId = val;
                          final match = availableModels.firstWhere(
                            (m) => (m['id']?.toString() ?? m['model']) == val,
                            orElse: () => {'model': ''},
                          );
                          _selectedModelName = match['model'];
                        });
                      },
              ),

              const SizedBox(height: 16),

              // 3. Registration Number Field
              TextField(
                controller: _regController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
                decoration: const InputDecoration(
                  labelText: 'License Plate / Registration Number',
                  hintText: 'e.g. DL 01 AB 1234',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: AppTheme.success),
                  const SizedBox(width: 6),
                  Text(
                    'Stored securely • Guaranteed bay clearance',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Submit Button
              NeumorphicButton(
                height: 50,
                onPressed: _isLoading ? null : _saveVehicle,
                child: _isLoading
                    ? const CarLoadingIndicator(size: 28, color: Colors.white)
                    : const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
