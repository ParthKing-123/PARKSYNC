import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddParkingScreen extends StatefulWidget {
  final String providerType;
  const AddParkingScreen({super.key, required this.providerType});

  @override
  State<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<AddParkingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    if (mounted) {
      // In real app, navigate to provider dashboard
      context.go('/provider-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking Space'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(_currentStep == 5 ? 'Submit' : 'Continue'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Location'),
            content: const TextField(
              decoration: InputDecoration(
                labelText: 'Search Address / PIN Code (India)',
                hintText: 'e.g. Area, City or 6-digit PIN code',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Space Details'),
            content: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Number of spaces available'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is the parking covered?'),
                  value: false,
                  onChanged: (val) {},
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                const Text('Dimensions (mm)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Length'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Width'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Height Clearance'), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Facilities & Security'),
            content: Column(
              children: [
                SwitchListTile(
                  title: const Text('CCTV Surveillance'),
                  value: true,
                  onChanged: (val) {},
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Security Guard / Access Control'),
                  value: false,
                  onChanged: (val) {},
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Photos'),
            content: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Tap to upload Entry, Space, and Exit photos')),
            ),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Availability & Price'),
            content: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Price per hour (₹)',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Operating Hours',
                    hintText: 'e.g. 09:00 AM - 06:00 PM',
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Verification Info'),
            content: const Text('As a business, you will need to submit proof of authorization before this listing goes live. Admin will verify it.'),
            isActive: _currentStep >= 5,
            state: _currentStep > 5 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
