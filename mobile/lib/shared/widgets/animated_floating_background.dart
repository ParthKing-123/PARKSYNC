import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../shared/theme/app_theme.dart';

/// Premium animated gradient background — used on auth / onboarding screens.
/// Features 3 slow-moving orbs with glassmorphism blur.
class AnimatedFloatingBackground extends StatefulWidget {
  final Widget child;

  const AnimatedFloatingBackground({super.key, required this.child});

  @override
  State<AnimatedFloatingBackground> createState() => _AnimatedFloatingBackgroundState();
}

class _AnimatedFloatingBackgroundState extends State<AnimatedFloatingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0F1E), Color(0xFF060910)],
            ),
          ),
        ),

        // Animated orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * pi;
            final size = MediaQuery.sizeOf(context);

            return Stack(
              children: [
                // Orb 1 – cyan, large, top area
                Positioned(
                  left: size.width * 0.15 + cos(t * 0.7) * 60,
                  top: size.height * 0.05 + sin(t * 0.7) * 80,
                  child: const _Orb(color: AppTheme.cyan, diameter: 280, opacity: 0.12),
                ),
                // Orb 2 – violet, mid-right
                Positioned(
                  right: size.width * 0.05 + sin(t * 0.5 + 1.2) * 50,
                  top: size.height * 0.35 + cos(t * 0.5 + 1.2) * 70,
                  child: const _Orb(color: AppTheme.violet, diameter: 240, opacity: 0.14),
                ),
                // Orb 3 – cyan tiny, bottom-left
                Positioned(
                  left: size.width * 0.05 + cos(t * 0.4 + 2.4) * 40,
                  bottom: size.height * 0.1 + sin(t * 0.4 + 2.4) * 60,
                  child: const _Orb(color: AppTheme.cyan, diameter: 160, opacity: 0.08),
                ),
              ],
            );
          },
        ),

        // Glassmorphism blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: const SizedBox.expand(),
          ),
        ),

        // Content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double diameter;
  final double opacity;

  const _Orb({required this.color, required this.diameter, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: (opacity * 1.8).clamp(0.0, 1.0)), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
