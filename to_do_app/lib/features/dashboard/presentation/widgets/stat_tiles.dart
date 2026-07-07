import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class _StatDef {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color soft;
  const _StatDef(this.label, this.value, this.icon, this.color, this.soft);
}

class StatTilesRow extends StatelessWidget {
  final int completed;
  final int pending;
  final int overdue;
  final int highPriority;

  const StatTilesRow({
    super.key,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.highPriority,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatDef('Completed', completed, Icons.check_rounded, AppColors.mint600, AppColors.mintSoft),
      _StatDef('Pending', pending, Icons.access_time_rounded, AppColors.sky700, AppColors.sky50),
      _StatDef('Overdue', overdue, Icons.local_fire_department_outlined, AppColors.coral600, AppColors.coralSoft),
      _StatDef('High Priority', highPriority, Icons.track_changes_outlined, AppColors.amber700, AppColors.amber50),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final perRow = constraints.maxWidth > 520 ? 4 : 2;
      final tileWidth = (constraints.maxWidth - (perRow - 1) * 12) / perRow;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats
            .map((s) => SizedBox(width: tileWidth, child: _StatTile(def: s)))
            .toList(),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final _StatDef def;
  const _StatTile({required this.def});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: def.soft, borderRadius: BorderRadius.circular(10)),
            child: Icon(def.icon, size: 18, color: def.color),
          ),
          const SizedBox(height: 12),
          Text('${def.value}', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(def.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
