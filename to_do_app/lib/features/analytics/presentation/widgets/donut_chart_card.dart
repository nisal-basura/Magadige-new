import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DonutSlice {
  final String label;
  final int value;
  final Color color;
  const DonutSlice(this.label, this.value, this.color);
}

class DonutChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<DonutSlice> slices;

  const DonutChartCard({super.key, required this.title, required this.subtitle, required this.slices});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = slices.fold<int>(0, (s, d) => s + d.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: total == 0
                    ? Center(child: Icon(Icons.donut_large_outlined, color: p.textTertiary))
                    : PieChart(
                        PieChartData(
                          sections: slices
                              .where((s) => s.value > 0)
                              .map((s) => PieChartSectionData(value: s.value.toDouble(), color: s.color, radius: 16, showTitle: false))
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: slices
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s.label, style: const TextStyle(fontSize: 12))),
                                Text('${s.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
