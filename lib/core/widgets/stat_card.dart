import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum StatCardColor { blue, green, purple, yellow }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final StatCardColor color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = StatCardColor.blue,
  });

  ({Color bg, Color icon}) _colors(bool isDark) {
    switch (color) {
      case StatCardColor.blue:
        return (
          bg: isDark ? AppColors.statBlueDark : AppColors.statBlueLight,
          icon: AppColors.statBlueIcon,
        );
      case StatCardColor.green:
        return (
          bg: isDark ? AppColors.statGreenDark : AppColors.statGreenLight,
          icon: AppColors.statGreenIcon,
        );
      case StatCardColor.purple:
        return (
          bg: isDark ? AppColors.statPurpleDark : AppColors.statPurpleLight,
          icon: AppColors.statPurpleIcon,
        );
      case StatCardColor.yellow:
        return (
          bg: isDark ? AppColors.statYellowDark : AppColors.statYellowLight,
          icon: AppColors.statYellowIcon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tones = _colors(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tones.bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: tones.icon, size: 22)],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(color: tones.icon),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
