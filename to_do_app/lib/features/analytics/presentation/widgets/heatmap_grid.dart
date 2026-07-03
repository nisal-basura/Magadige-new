import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Deterministic pseudo-random consistency heatmap — same spirit as the
/// web app's 12-week contribution grid (a stand-in until real daily
/// completion history comes from a backend).
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const seed = 42;
    final cells = List.generate(84, (i) {
      final v = (seed * (i + 3) * 9301 + 49297) % 233280 / 233280;
      final level = v > 0.82 ? 3 : v > 0.6 ? 2 : v > 0.35 ? 1 : 0;
      final colors = [p.bgSunken, p.brandSoft, p.brand.withValues(alpha: 0.55), p.brand];
      return Container(width: 14, height: 14, decoration: BoxDecoration(color: colors[level], borderRadius: BorderRadius.circular(3)));
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Consistency Heatmap', style: Theme.of(context).textTheme.titleLarge),
          Text('Your last 12 weeks of activity', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          Wrap(spacing: 4, runSpacing: 4, children: cells),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 6),
              ...[p.bgSunken, p.brandSoft, p.brand.withValues(alpha: 0.55), p.brand]
                  .map((c) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)))),
              const SizedBox(width: 4),
              Text('More', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
