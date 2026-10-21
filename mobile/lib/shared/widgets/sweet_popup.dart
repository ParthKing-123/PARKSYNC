import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sweet animated popup toast for item saved, booking confirmed, and action feedback.
class SweetPopup {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData icon = Icons.bookmark_added_rounded,
    Color? iconColor,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _SweetPopupOverlay(
        message: message,
        title: title,
        icon: icon,
        iconColor: iconColor,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _SweetPopupOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final IconData icon;
  final Color? iconColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SweetPopupOverlay({
    required this.message,
    this.title,
    required this.icon,
    this.iconColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SweetPopupOverlay> createState() => _SweetPopupOverlayState();
}

class _SweetPopupOverlayState extends State<_SweetPopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppTheme.forestSurface : AppTheme.butterElevated;
    final fg = isDark ? AppTheme.butter : AppTheme.forestGreen;
    final iconTint = widget.iconColor ?? (isDark ? AppTheme.butter : AppTheme.forestGreen);

    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.forestHighlight.withValues(alpha: 0.5)
                              : AppTheme.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: AppTheme.neumorphicShadows(
                          isDark: isDark,
                          distance: 6.0,
                          blur: 16.0,
                          intensity: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.butter.withValues(alpha: 0.15)
                                  : AppTheme.forestGreen.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              size: 18,
                              color: iconTint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null) ...[
                                  Text(
                                    widget.title!,
                                    style: TextStyle(
                                      color: fg,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Bouncy animated bookmark / save button with instant Sweet Popup feedback.
class SweetBookmarkButton extends StatefulWidget {
  final bool isSaved;
  final ValueChanged<bool>? onToggle;
  final String itemName;
  final double size;

  const SweetBookmarkButton({
    super.key,
    required this.isSaved,
    this.onToggle,
    this.itemName = 'Spot',
    this.size = 38.0,
  });

  @override
  State<SweetBookmarkButton> createState() => _SweetBookmarkButtonState();
}

class _SweetBookmarkButtonState extends State<SweetBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _handleTap() {
    _anim.forward(from: 0.0);
    final nextState = !widget.isSaved;
    widget.onToggle?.call(nextState);

    SweetPopup.show(
      context,
      title: nextState ? 'Saved to Favorites!' : 'Removed from Favorites',
      message: nextState
          ? '${widget.itemName} has been saved to your list.'
          : '${widget.itemName} removed from saved list.',
      icon: nextState ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
      iconColor: nextState ? AppTheme.amber : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.forestSurface : AppTheme.butterCream,
            shape: BoxShape.circle,
            boxShadow: AppTheme.neumorphicShadows(isDark: isDark, distance: 2.5, blur: 5),
            border: Border.all(
              color: isDark ? AppTheme.forestHighlight : AppTheme.butterHighlight,
              width: 0.8,
            ),
          ),
          child: Icon(
            widget.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: widget.isSaved ? AppTheme.amber : (isDark ? AppTheme.butter : AppTheme.forestGreen),
            size: widget.size * 0.52,
          ),
        ),
      ),
    );
  }
}
