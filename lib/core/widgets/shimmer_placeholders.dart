import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEmployeeList extends StatelessWidget {
  final int itemCount;

  const ShimmerEmployeeList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF20263A) : const Color(0xFFE6E9F0);
    final highlight = isDark ? const Color(0xFF2C3350) : const Color(0xFFF4F6FA);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 140, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 180, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 100, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerStatGrid extends StatelessWidget {
  const ShimmerStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF20263A) : const Color(0xFFE6E9F0);
    final highlight = isDark ? const Color(0xFF2C3350) : const Color(0xFFF4F6FA);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.5,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}