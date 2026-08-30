import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CountryBarChart extends StatelessWidget {
  final Map<String, int> countsByCountry;
  final int maxBars;

  const CountryBarChart({
    super.key,
    required this.countsByCountry,
    this.maxBars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = countsByCountry.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = entries.take(maxBars).toList();
    final maxValue = topEntries.isEmpty
        ? 1
        : topEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (topEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topEntries.map((entry) {
        final fraction = entry.value / maxValue;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Stack(
                        children: [
                          Container(
                            height: 22,
                            color: theme.dividerColor.withValues(alpha: 0.3),
                          ),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.statBlueIcon,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  '${entry.value}',
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
