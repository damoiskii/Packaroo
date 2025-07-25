import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final bool showTooltip;

  const AppIcon({
    super.key,
    this.size = 32,
    this.showTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Image.asset(
      'assets/icons/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a default icon if the asset fails to load
        return Icon(
          Icons.inventory_2,
          size: size,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );

    if (showTooltip) {
      return Tooltip(
        message: 'Packaroo - Java Application Packager',
        child: icon,
      );
    }

    return icon;
  }
}
