import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

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
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isLoading = false);
    
    if (mounted) {
      SweetPopup.show(
        context,
        title: 'Listing Submitted!',
        message: 'Your parking space is submitted for platform verification.',
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        context.go('/provider-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Parking Space',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
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
                  child: NeumorphicButton(
                    height: 48,
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_currentStep == 5 ? 'Submit for Review' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
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
                const Row(
                  children: [
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Length'), keyboardType: TextInputType.number)),
                    SizedBox(width: 8),
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Width'), keyboardType: TextInputType.number)),
                    SizedBox(width: 8),
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
            content: NeumorphicCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.forestGreen),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to upload Entry, Bay & Exit photos',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Availability & Price'),
            content: const Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Price per hour (₹)',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
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
            content: const Text('As a business or private host, you will need to submit proof of authorization before this listing goes live. Admin will verify it.'),
            isActive: _currentStep >= 5,
            state: _currentStep > 5 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
