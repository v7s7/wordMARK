import 'package:flutter/material.dart';

/// Centers content and caps it at [maxWidth].
/// Keeps mobile feeling on narrow screens, clean centered layout on web/iPad.
class MaxWidthView extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const MaxWidthView({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
