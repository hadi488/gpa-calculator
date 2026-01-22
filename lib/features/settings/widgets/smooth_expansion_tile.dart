import 'package:flutter/material.dart';

class SmoothExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Curve curve;
  final Duration duration;
  final Color? collapsedBackgroundColor;
  final Color? backgroundColor;

  const SmoothExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.collapsedBackgroundColor,
    this.backgroundColor,
  });

  @override
  State<SmoothExpansionTile> createState() => _SmoothExpansionTileState();
}

class _SmoothExpansionTileState extends State<SmoothExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: widget.curve));
    _isExpanded =
        PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children to remove them from tree?
            // Standard ExpansionTile keeps them but with height 0.
            // keeping them is fine.
          });
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
      color: _isExpanded
          ? widget.backgroundColor ?? Colors.transparent
          : widget.collapsedBackgroundColor ?? Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: _handleTap,
            leading: widget.leading,
            title: widget.title,
            subtitle: widget.subtitle,
            trailing: RotationTransition(
              turns: _controller.drive(
                Tween<double>(
                  begin: 0.0,
                  end: 0.5,
                ).chain(CurveTween(curve: Curves.easeIn)),
              ),
              child: const Icon(Icons.expand_more),
            ),
          ),
          ClipRect(
            child: Align(heightFactor: _heightFactor.value, child: child),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
