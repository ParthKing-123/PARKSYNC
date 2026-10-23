import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_client.dart';
import '../../../core/user_state_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/animated_floating_background.dart';
import '../../../shared/widgets/car_loading_indicator.dart';
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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

    // Password validation
    if (password.length < 6) {
      SweetPopup.show(
        context,
        title: 'Password Too Short',
        message: 'Please create a password of at least 6 characters.',
        icon: Icons.lock_outline_rounded,
        iconColor: AppTheme.error,
      );
      return;
    }

    if (password != confirmPassword) {
      SweetPopup.show(
        context,
        title: 'Passwords Do Not Match',
        message: 'Please re-type your password identically in both fields.',
        icon: Icons.lock_reset_rounded,
        iconColor: AppTheme.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final phone = UserStateService.instance.phoneNumber;

    // 1. Persist to backend
    try {
      final response = await ApiClient().dio.post('/auth/register-profile', data: {
        'phone': phone,
        'name': name,
        'email': email.isNotEmpty ? email : null,
        'password': password,
        'role': 'SEEKER',
      });

      if (response.data != null && response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.data['token'].toString());
      }
    } catch (e) {
      debugPrint('[Auth] Backend register-profile unreachable or error: $e');
    }

    // 2. Persist locally in UserStateService for direct 0-OTP login in future
    await UserStateService.instance.savePassword(phone, password);
    await UserStateService.instance.updateProfile(
      name: name,
      email: email,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      SweetPopup.show(
        context,
        title: 'Profile & Password Created!',
        message: 'Welcome $name! Password saved. You can now log in anytime without OTP.',
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 700));

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
        title: Text(
          'Step 1 of 2: Driver Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
        ),
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
                // Step Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.accentGold : AppTheme.forestGreen)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Header Info
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your driver details and security password for instant direct sign-in next time.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 24),

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
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

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
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Create Password Field ────────────────────────────────────
                Text(
                  'Create Password *',
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
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _obscurePassword ? 2.0 : 0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        letterSpacing: 0,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      ),
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

                const SizedBox(height: 18),

                // ── Confirm Password Field ───────────────────────────────────
                Text(
                  'Confirm Password *',
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
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _obscureConfirmPassword ? 2.0 : 0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        letterSpacing: 0,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        size: 20,
                        color: isDark ? AppTheme.accentGold : AppTheme.forestGreen,
                      ),
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

                const SizedBox(height: 18),

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

                const SizedBox(height: 32),

                // Save & Continue Action
                NeumorphicButton(
                  height: 52,
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CarLoadingIndicator(size: 26)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Save Password & Continue to Vehicle',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
