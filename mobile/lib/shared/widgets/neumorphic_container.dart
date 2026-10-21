import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive Neumorphic Card container with tactile spring press feedback.
class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Border? border;
  final bool isPressed;
  final double depth;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.radius = 18.0,
    this.color,
    this.border,
    this.isPressed = false,
    this.depth = 4.0,
  });

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> with SingleTickerProviderStateMixin {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pressed = widget.isPressed || _isDown;

    final boxDeco = AppTheme.neumorphicBox(
      isDark: isDark,
      isPressed: pressed,
      radius: widget.radius,
      color: widget.color,
      border: widget.border,
    );

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      margin: widget.margin,
      decoration: boxDeco,
      child: widget.child,
    );

    if (widget.onTap != null) {
      container = GestureDetector(
        onTapDown: (_) => setState(() => _isDown = true),
        onTapUp: (_) => setState(() => _isDown = false),
        onTapCancel: () => setState(() => _isDown = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Neumorphic Button with butter/forest fill and tactile depth.
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final bool isPrimary;
  final double height;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.radius = 16.0,
    this.padding,
    this.isPrimary = true,
    this.height = 52.0,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onPressed != null;

    Color bg;
    Color fg;

    if (widget.isPrimary) {
      bg = isDark ? AppTheme.butter : AppTheme.forestGreen;
      fg = isDark ? AppTheme.forestGreenDark : AppTheme.butter;
    } else {
      bg = isDark ? AppTheme.bgSurfaceDark : AppTheme.bgSurfaceLight;
      fg = isDark ? AppTheme.butter : AppTheme.forestGreen;
    }

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isDown = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isDown = false) : null,
      onTapCancel: enabled ? () => setState(() => _isDown = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isDown ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: _isDown
                ? AppTheme.neumorphicPressedShadows(isDark: isDark)
                : AppTheme.neumorphicShadows(isDark: isDark, distance: 3.5, blur: 8),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Neumorphic circular badge or icon button
class NeumorphicIconBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? iconColor;

  const NeumorphicIconBadge({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44.0,
    this.iconSize = 20.0,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppTheme.bgSurfaceDark : AppTheme.bgSurfaceLight);
    final fg = iconColor ?? (isDark ? AppTheme.butter : AppTheme.forestGreen);

    final widget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 2.5, blur: 6),
        border: Border.all(
          color: isDark ? AppTheme.forestHighlight.withValues(alpha: 0.3) : AppTheme.butterHighlight.withValues(alpha: 0.8),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Icon(icon, color: fg, size: iconSize),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: widget,
      );
    }
    return widget;
  }
}
