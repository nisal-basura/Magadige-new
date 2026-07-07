import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/priority_dot.dart';
import '../../../../data/models/badge_model.dart';
import '../../../../data/models/dream_model.dart';
import '../../../../data/models/task_model.dart';

class BadgesPreview extends StatelessWidget {
  final List<UserBadgeModel> badges;
  const BadgesPreview({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shown = badges.take(6).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
          Text('Badges earned', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shown.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
            itemBuilder: (context, i) {
              final b = shown[i];
              return Opacity(
                opacity: b.earned ? 1 : 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
                      child: Icon(b.badge.icon, size: 20, color: p.brandStrong),
                    ),
                    const SizedBox(height: 6),
                    Text(b.badge.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DreamNudgeCard extends StatelessWidget {
  final DreamModel? dream;
  final VoidCallback onView;
  const DreamNudgeCard({super.key, required this.dream, required this.onView});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (dream == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DREAM PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: p.brand)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(dream!.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(dream!.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        Text('${dream!.progress}%', style: TextStyle(color: p.brand, fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppProgressBar(progress: dream!.progress, height: 6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onView, child: const Text('View'))),
        ],
      ),
    );
  }
}

class UpcomingTasksList extends StatelessWidget {
  final List<TaskModel> tasks;
  const UpcomingTasksList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Tasks', style: Theme.of(context).textTheme.titleLarge),
          Text("What's next on deck", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text("No upcoming tasks scheduled — you're all caught up.", style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            ...tasks.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: p.bgSunken, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.due == null ? '—' : '${t.due!.day}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1)),
                            if (t.due != null)
                              Text(DateFormat('MMM').format(t.due!).toUpperCase(), style: TextStyle(fontSize: 8, color: p.textTertiary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                            Row(children: [
                              PriorityDot(priority: t.priority, size: 6),
                              const SizedBox(width: 5),
                              Text(t.category.label, style: Theme.of(context).textTheme.bodySmall),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class RecentActivityList extends StatelessWidget {
  final List<ActivityModel> activity;
  const RecentActivityList({super.key, required this.activity});

  IconData _iconFor(String type) => switch (type) {
        'complete' => Icons.check_rounded,
        'create' => Icons.add_rounded,
        'dream' => Icons.star_border_rounded,
        'badge' => Icons.emoji_events_outlined,
        'overdue' => Icons.local_fire_department_outlined,
        _ => Icons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
          Text('Your latest actions', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ...activity.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
                      child: Icon(_iconFor(a.type), size: 14, color: p.brandStrong),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                          Text(a.time, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
