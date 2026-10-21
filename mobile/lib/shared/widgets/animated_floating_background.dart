import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Premium animated floating background — theme-aware with Butter & Forest Green orbs.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColors = isDark
        ? [AppTheme.forestBase, const Color(0xFF04100D)]
        : [AppTheme.butter, const Color(0xFFFFF6D1)];

    final orbColor1 = isDark ? AppTheme.butter : AppTheme.forestGreen;
    final orbColor2 = isDark ? AppTheme.forestEmerald : const Color(0xFFE2C882);
    final orbColor3 = isDark ? AppTheme.forestGreenLight : AppTheme.forestGreen;

    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
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
                // Orb 1 – top area
                Positioned(
                  left: size.width * 0.15 + cos(t * 0.7) * 60,
                  top: size.height * 0.05 + sin(t * 0.7) * 80,
                  child: _Orb(color: orbColor1, diameter: 280, opacity: isDark ? 0.09 : 0.10),
                ),
                // Orb 2 – mid-right
                Positioned(
                  right: size.width * 0.05 + sin(t * 0.5 + 1.2) * 50,
                  top: size.height * 0.35 + cos(t * 0.5 + 1.2) * 70,
                  child: _Orb(color: orbColor2, diameter: 240, opacity: isDark ? 0.12 : 0.18),
                ),
                // Orb 3 – bottom-left
                Positioned(
                  left: size.width * 0.05 + cos(t * 0.4 + 2.4) * 40,
                  bottom: size.height * 0.1 + sin(t * 0.4 + 2.4) * 60,
                  child: _Orb(color: orbColor3, diameter: 160, opacity: isDark ? 0.08 : 0.08),
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
          colors: [
            color.withValues(alpha: (opacity * 1.8).clamp(0.0, 1.0)),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
