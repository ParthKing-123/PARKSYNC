import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _carDriveIn;
  late Animation<double> _carMorph;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Car drives in fast from left (0 to 1)
    _carDriveIn = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Car morphs/scales down to 0 (1 to 0)
    _carMorph = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.7, curve: Curves.easeInExpo),
      ),
    );

    // 3. Logo bursts out (0 to 1)
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Logo fades in
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 0.8, curve: Curves.easeIn),
      ),
    );

    _mainController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) context.go('/guest-home');
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Phase 1 & 2: The Car
                if (_carMorph.value > 0)
                  Transform.translate(
                    offset: Offset(_carDriveIn.value, 0),
                    child: Transform.scale(
                      scale: _carMorph.value,
                      child: Icon(
                        CupertinoIcons.car_detailed,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                // Phase 3: The Logo
                if (_logoOpacity.value > 0)
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 6, blur: 16),
                              border: Border.all(
                                color: isDark ? AppTheme.forestHighlight : AppTheme.butterHighlight,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_parking_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ParkSync',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Parking Marketplace for India',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
