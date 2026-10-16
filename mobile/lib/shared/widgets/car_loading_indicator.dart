import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CarLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  
  const CarLoadingIndicator({super.key, this.size = 60.0, this.color});

  @override
  State<CarLoadingIndicator> createState() => _CarLoadingIndicatorState();
}

class _CarLoadingIndicatorState extends State<CarLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _roadController;

  @override
  void initState() {
    super.initState();
    
    // Car suspension bounce
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    // Road moving fast
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _roadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The bouncing car
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -5 + (_bounceController.value * 4)),
                child: Icon(
                  CupertinoIcons.car_detailed,
                  size: widget.size * 0.8,
                  color: themeColor,
                ),
              );
            },
          ),
          
          // The moving road
          Positioned(
            bottom: widget.size * 0.1,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _roadController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size * 1.5, 4),
                  painter: _RoadPainter(
                    progress: _roadController.value,
                    color: themeColor.withValues(alpha: 0.5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RoadPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dashWidth = size.width * 0.3;
    final dashSpace = size.width * 0.2;
    
    // Shift the road to the left based on progress
    double startX = size.width - (progress * (dashWidth + dashSpace));

    // Draw 3 dashes to create infinite loop illusion
    for (int i = 0; i < 4; i++) {
      double x = startX - (i * (dashWidth + dashSpace));
      if (x + dashWidth > 0 && x < size.width) {
        // Only draw if visible
        canvas.drawLine(
          Offset(x.clamp(0, size.width), size.height / 2),
          Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.color != color;
}
