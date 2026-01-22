import 'package:flutter/material.dart';

/// A widget that applies a slide and fade transition to its child with a delay.
///
/// Useful for staggered list animations.
class SlideFadeTransition extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// The delay before starting the animation (in milliseconds)
  final int delay;

  /// The duration of the animation
  final Duration duration;

  /// The vertical offset for the slide (default: 50.0)
  final double yOffset;

  /// The curve of the animation
  final Curve curve;

  const SlideFadeTransition({
    super.key,
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 400),
    this.yOffset = 50.0,
    this.curve = Curves.easeOutQuart,
  });

  @override
  State<SlideFadeTransition> createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.yOffset / 100), // Approximate relative offset
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation after delay
    if (widget.delay == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
