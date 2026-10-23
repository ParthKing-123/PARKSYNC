import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/user_state_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/animated_floating_background.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class SeekerProfileScreen extends StatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  State<SeekerProfileScreen> createState() => _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends State<SeekerProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCity = 'Pune';
  bool _isLoading = false;

  final List<String> _indianCities = [
    'Pune',
    'Mumbai',
    'Delhi NCR',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
    'Chandigarh',
  ];

  @override
  void initState() {
    super.initState();
    final currentName = UserStateService.instance.userName;
    if (currentName != 'Verified Driver' && currentName != 'Guest Driver') {
      _nameController.text = currentName;
    }
    _emailController.text = UserStateService.instance.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) return true;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.length < 2) {
      SweetPopup.show(
        context,
        title: 'Full Name Required',
        message: 'Please enter your full name (minimum 2 characters).',
        icon: Icons.person_outline_rounded,
        iconColor: AppTheme.error,
      );
      return;
    }

    if (email.isNotEmpty && !_validateEmail(email)) {
      SweetPopup.show(
        context,
        title: 'Invalid Email',
        message: 'Please provide a valid email format or leave it blank.',
        icon: Icons.email_outlined,
        iconColor: AppTheme.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    await UserStateService.instance.updateProfile(
      name: name,
      email: email,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      SweetPopup.show(
        context,
        title: 'Profile Updated!',
        message: 'Welcome $name, let\'s add your vehicle for auto-compatibility.',
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        context.push('/seeker-vehicle-setup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
            onPressed: () => context.go('/guest-home'),
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
      body: AnimatedFloatingBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.forestGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Step 1 of 2 • Driver Profile',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Complete your\ndriver profile.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hosts verify driver identity before parking check-in. Your details are strictly encrypted.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 28),

                // Name Field (Required)
                Text(
                  'Full Name *',
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
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Rahul Patil',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Email Field (Optional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.forestElevated : const Color(0xFFEFE8D0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                NeumorphicCard(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. rahul@gmail.com (for receipts)',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Primary City Selector
                Text(
                  'Primary Parking City',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                NeumorphicCard(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                      ),
                      dropdownColor: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                      items: _indianCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                size: 18,
                                color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                city,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCity = val);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Save & Continue Action
                NeumorphicButton(
                  height: 52,
                  onPressed: _isLoading ? null : _saveProfile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue to Vehicle Setup',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: isDark ? AppTheme.forestGreenDark : AppTheme.butter,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/guest-home'),
                    child: Text(
                      'I\'ll complete this later (Skip)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
