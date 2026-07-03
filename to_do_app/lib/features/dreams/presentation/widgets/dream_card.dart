import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../data/models/dream_model.dart';

class DreamCard extends StatelessWidget {
  final DreamModel dream;
  final VoidCallback onTap;

  const DreamCard({super.key, required this.dream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final daysLeft = dream.daysLeft;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.borderSubtle)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: p.bgSunken, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text(dream.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  Icon(Icons.more_horiz_rounded, color: p.textTertiary),
                ],
              ),
              const SizedBox(height: 12),
              Text(dream.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '"${dream.motivation}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress', style: Theme.of(context).textTheme.bodySmall),
                  Text('${dream.progress}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              AppProgressBar(progress: dream.progress, gradient: [dream.color, p.secondary]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: p.borderSubtle))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(daysLeft > 0 ? '$daysLeft days left' : 'Target date passed', style: Theme.of(context).textTheme.bodySmall),
                    Text('Target: ${DateFormat('MMM y').format(dream.target)}', style: Theme.of(context).textTheme.bodySmall),
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
