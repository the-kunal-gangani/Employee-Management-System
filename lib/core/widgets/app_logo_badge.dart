import 'package:flutter/material.dart';

class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.groups_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}
