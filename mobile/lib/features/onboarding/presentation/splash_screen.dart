import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.go('/role-selection');
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
    return Scaffold(
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
                          Text(
                            'ParkSync',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Parking made simple.',
                            style: Theme.of(context).textTheme.bodyLarge,
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
