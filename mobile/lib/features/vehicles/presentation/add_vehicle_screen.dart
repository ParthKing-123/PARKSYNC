import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api_client.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/car_loading_indicator.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String? _selectedMake;
  String? _selectedModelId;
  final _regController = TextEditingController();
  bool _isLoading = false;
  bool _isFetchingModels = true;
  
  List<dynamic> _vehicleModels = [];
  List<String> _makes = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicleModels();
  }

  void _fetchVehicleModels() async {
    try {
      final response = await ApiClient().dio.get('/vehicles/models');
      final models = response.data as List<dynamic>;
      
      final makesSet = <String>{};
      for (var m in models) {
        makesSet.add(m['make']);
      }
      
      if (mounted) {
        setState(() {
          _vehicleModels = models;
          _makes = makesSet.toList()..sort();
          _isFetchingModels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingModels = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load vehicle models')));
      }
    }
  }

  void _saveVehicle() async {
    if (_selectedMake == null || _selectedModelId == null || _regController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ApiClient().dio.post('/vehicles', data: {
        'vehicleModelId': _selectedModelId,
        'registrationNumber': _regController.text,
        'isPrimary': true,
      });
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save vehicle')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingModels) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonLoader(width: double.infinity, height: 400)),
      );
    }

    // Filter models for the selected make
    final availableModels = _vehicleModels.where((m) => m['make'] == _selectedMake).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your vehicle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We use your vehicle model to find parking spaces that fit perfectly.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Make (e.g. Hyundai)'),
                value: _selectedMake,
                items: _makes.map((make) {
                  return DropdownMenuItem(value: make, child: Text(make));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMake = val;
                    _selectedModelId = null; // reset model when make changes
                  });
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Model'),
                value: _selectedModelId,
                items: availableModels.map((model) {
                  return DropdownMenuItem<String>(value: model['id'], child: Text("${model['model']} ${model['year'] ?? ''}"));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedModelId = val);
                },
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _regController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  hintText: 'MH 12 AB 1234',
                ),
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: (_isLoading || _selectedModelId == null) ? null : _saveVehicle,
                child: _isLoading 
                    ? const CarLoadingIndicator(size: 30, color: Colors.black)
                    : const Text('Save & Continue'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
