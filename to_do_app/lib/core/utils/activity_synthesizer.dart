import '../../data/models/badge_model.dart';
import '../../data/models/task_model.dart';
import 'relative_time.dart';

/// There's no activity-log endpoint anywhere on the backend, so the
/// dashboard's "Recent Activity" feed is built here from data we already
/// have — recently completed/created tasks and recently earned badges,
/// merged and sorted by time. Real data, just not a true audit log.
List<ActivityModel> synthesizeActivity({
  required List<TaskModel> tasks,
  required List<UserBadgeModel> badges,
  int limit = 8,
}) {
  final entries = <(DateTime, ActivityModel)>[];

  for (final task in tasks) {
    final completedAt = task.completedAt;
    if (completedAt != null) {
      entries.add((completedAt, ActivityModel(id: 'complete-${task.id}', type: 'complete', text: 'Completed "${task.title}"', time: relativeTime(completedAt))));
    }
    entries.add((task.createdAt, ActivityModel(id: 'create-${task.id}', type: 'create', text: 'Added new task "${task.title}"', time: relativeTime(task.createdAt))));
  }

  for (final userBadge in badges) {
    final earnedDate = userBadge.earnedDate;
    if (userBadge.earned && earnedDate != null) {
      entries.add((earnedDate, ActivityModel(id: 'badge-${userBadge.badge.id}', type: 'badge', text: 'Earned badge "${userBadge.badge.label}"', time: relativeTime(earnedDate))));
    }
  }

  entries.sort((a, b) => b.$1.compareTo(a.$1));
  return entries.take(limit).map((e) => e.$2).toList();
}
