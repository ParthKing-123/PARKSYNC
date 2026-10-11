import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedFloatingBackground extends StatefulWidget {
  final Widget child;

  const AnimatedFloatingBackground({super.key, required this.child});

  @override
  State<AnimatedFloatingBackground> createState() => _AnimatedFloatingBackgroundState();
}

class _AnimatedFloatingBackgroundState extends State<AnimatedFloatingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
        // Background color
        Container(color: Theme.of(context).colorScheme.background),
        
        // Animated floating orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value * 2 * pi;
            final size = MediaQuery.of(context).size;
            
            return Stack(
              children: [
                // Orb 1 (Cyan/Primary)
                Positioned(
                  left: (size.width / 2) + cos(t) * 150 - 100,
                  top: (size.height / 3) + sin(t) * 150 - 100,
                  child: _buildOrb(Theme.of(context).colorScheme.primary, 250),
                ),
                // Orb 2 (Yellow/Secondary)
                Positioned(
                  right: (size.width / 2) + sin(t + pi) * 100 - 100,
                  bottom: (size.height / 3) + cos(t + pi) * 100 - 100,
                  child: _buildOrb(Theme.of(context).colorScheme.secondary, 200),
                ),
                // Orb 3 (Accent)
                Positioned(
                  left: (size.width / 4) + cos(t + pi / 2) * 80 - 100,
                  bottom: (size.height / 5) + sin(t + pi / 2) * 80 - 100,
                  child: _buildOrb(Theme.of(context).colorScheme.primary.withOpacity(0.5), 150),
                ),
              ],
            );
          },
        ),

        // Blur overlay (Glassmorphism effect over the orbs)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Foreground content
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Widget _buildOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
