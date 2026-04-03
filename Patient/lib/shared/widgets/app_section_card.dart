import 'package:flutter/material.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      child: Padding(
        padding: padding!,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Theme.of(context).cardTheme.shape is RoundedRectangleBorder 
            ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context)).topLeft.x
            : 24.0),
        child: card,
      );
    }

    return card;
  }
}

