import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/seed_data.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final data = SeedData.weeklyProgress;
    final maxTotal = data.map((d) => d['total']!).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Progress', style: Theme.of(context).textTheme.titleLarge),
                Text('Tasks completed vs. planned', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxTotal + 1,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(SeedData.weekdayLabels[value.toInt()], style: TextStyle(fontSize: 10, color: p.textTertiary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final total = data[i]['total']!.toDouble();
                  final completed = data[i]['completed']!.toDouble();
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: total,
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                      color: p.bgSunken,
                      rodStackItems: [
                        BarChartRodStackItem(0, completed, p.brand),
                        BarChartRodStackItem(completed, total, p.bgSunken),
                      ],
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyLineChart extends StatelessWidget {
  const MonthlyLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final values = SeedData.monthlyProgress;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Progress', style: Theme.of(context).textTheme.titleLarge),
                Text('Completion rate over 12 months', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: 0,
                maxY: 100,
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i].toDouble())),
                    isCurved: true,
                    color: p.brand,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [p.brand.withValues(alpha: 0.28), p.brand.withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductivityScoreCard extends StatelessWidget {
  final int score;
  final int streakCurrent;
  final int streakLongest;
  final int completionRate;

  const ProductivityScoreCard({
    super.key,
    required this.score,
    required this.streakCurrent,
    required this.streakLongest,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ring = _ScoreRing(score: score);
    final details = Column(
      children: [
        _detailRow(context, 'Current streak', '$streakCurrent days'),
        _detailRow(context, 'Longest streak', '$streakLongest days'),
        _detailRow(context, 'Completion rate', '$completionRate%', showDivider: false),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Productivity Score', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Below ~300 logical px of content width (small phones, or large
          // system font scaling) the ring + detail rows can't share a row
          // without the text getting cramped, so stack them instead.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  children: [
                    Center(child: ring),
                    const SizedBox(height: 16),
                    details,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ring,
                  const SizedBox(width: 18),
                  Expanded(child: details),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool showDivider = true}) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: p.borderSubtle)) : null),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 9,
              backgroundColor: p.bgSunken,
              valueColor: AlwaysStoppedAnimation(p.brand),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: Theme.of(context).textTheme.headlineSmall),
              Text('SCORE', style: TextStyle(fontSize: 9, color: p.textTertiary, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
