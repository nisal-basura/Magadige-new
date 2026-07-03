import 'package:flutter/material.dart';

import '../models/badge_model.dart';
import '../models/category_model.dart';
import '../models/dream_model.dart';
import '../models/notification_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../../core/theme/app_colors.dart';

/// Static seed/demo data — the Dart equivalent of js/data.js. This is what
/// the Mock*Repository implementations serve until a real backend is wired
/// in; the shapes here are exactly what the API layer will eventually need
/// to return.
class SeedData {
  SeedData._();

  static DateTime _d(int y, int m, int d) => DateTime(y, m, d);

  static final UserModel user = UserModel(
    name: 'Amaka Nwosu',
    role: 'Product Designer @ Northwind Labs',
    email: 'nbcodezone@gmail.com',
    avatarInitials: 'AN',
    memberSince: 'March 2024',
    timezone: 'GMT+1 · Lagos',
    streakCurrent: 12,
    streakLongest: 34,
    productivityScore: 87,
    plan: 'Premium Plan',
  );

  static List<TaskModel> tasks() => [
        TaskModel(
          id: 't1',
          title: 'Finalize onboarding flow wireframes',
          description: 'Polish the 5-step onboarding wireframes and prep for the Friday design crit with the growth team.',
          category: TaskCategory.work,
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          due: _d(2026, 7, 2),
          tags: const ['design', 'onboarding'],
          estimate: '3h',
          progress: 65,
          favorite: true,
          createdAt: _d(2026, 6, 28),
          subtasks: const ['Research & plan approach', 'Execute the core work', 'Review with a peer', 'Polish & finalize', 'Mark as complete'],
        ),
        TaskModel(
          id: 't2',
          title: 'Morning run — 5km',
          description: 'Easy pace, focus on breathing rhythm.',
          category: TaskCategory.health,
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          due: _d(2026, 7, 2),
          tags: const ['fitness'],
          estimate: '40m',
          createdAt: _d(2026, 6, 30),
        ),
        TaskModel(
          id: 't3',
          title: 'Review Q3 budget spreadsheet',
          description: 'Cross-check marketing spend against approved budget lines before the finance sync.',
          category: TaskCategory.finance,
          priority: TaskPriority.high,
          status: TaskStatus.overdue,
          due: _d(2026, 6, 30),
          tags: const ['budget', 'review'],
          estimate: '1h',
          progress: 20,
          createdAt: _d(2026, 6, 25),
        ),
        TaskModel(
          id: 't4',
          title: "Read 'Deep Work' — Ch. 4",
          description: 'Continue reading, take notes for the book club discussion.',
          category: TaskCategory.learning,
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          due: _d(2026, 7, 3),
          tags: const ['reading'],
          estimate: '45m',
          progress: 10,
          createdAt: _d(2026, 6, 29),
        ),
        TaskModel(
          id: 't5',
          title: 'Prepare investor update email',
          description: 'Summarize product milestones and MRR growth for the monthly investor newsletter.',
          category: TaskCategory.work,
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          due: _d(2026, 7, 4),
          tags: const ['startup', 'writing'],
          estimate: '2h',
          favorite: true,
          createdAt: _d(2026, 7, 1),
          dreamId: 'd2',
        ),
        TaskModel(
          id: 't6',
          title: 'Grocery run for the week',
          description: 'Get produce, oats, and coffee beans.',
          category: TaskCategory.personal,
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          due: _d(2026, 7, 1),
          tags: const ['errands'],
          estimate: '30m',
          progress: 100,
          createdAt: _d(2026, 6, 27),
        ),
        TaskModel(
          id: 't7',
          title: 'Design system: audit color tokens',
          description: 'Ensure new brand tokens map cleanly across day/night themes.',
          category: TaskCategory.work,
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          due: _d(2026, 6, 29),
          tags: const ['design-system'],
          estimate: '1.5h',
          progress: 100,
          createdAt: _d(2026, 6, 24),
        ),
        TaskModel(
          id: 't8',
          title: 'Call mum',
          description: 'Weekly catch-up call.',
          category: TaskCategory.personal,
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          due: _d(2026, 6, 30),
          tags: const ['family'],
          estimate: '20m',
          progress: 100,
          favorite: true,
          createdAt: _d(2026, 6, 30),
        ),
        TaskModel(
          id: 't9',
          title: 'Yoga & stretching session',
          description: 'Focus on hips and shoulders.',
          category: TaskCategory.health,
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          due: _d(2026, 7, 2),
          tags: const ['fitness', 'recovery'],
          estimate: '25m',
          createdAt: _d(2026, 7, 1),
        ),
        TaskModel(
          id: 't10',
          title: 'Refactor auth service tests',
          description: 'Increase coverage on token refresh edge cases.',
          category: TaskCategory.work,
          priority: TaskPriority.medium,
          status: TaskStatus.overdue,
          due: _d(2026, 6, 28),
          tags: const ['engineering'],
          estimate: '2h',
          progress: 40,
          createdAt: _d(2026, 6, 22),
        ),
        TaskModel(
          id: 't11',
          title: 'Plan Japan itinerary — Kyoto leg',
          description: 'Map temples, ryokan stay, and food spots for the 4-day Kyoto stretch.',
          category: TaskCategory.personal,
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          due: _d(2026, 7, 6),
          tags: const ['travel'],
          estimate: '1h',
          progress: 15,
          favorite: true,
          createdAt: _d(2026, 6, 26),
          dreamId: 'd3',
        ),
        TaskModel(
          id: 't12',
          title: 'Study system design — caching patterns',
          description: 'Notes on write-through vs write-behind caches for the architect track.',
          category: TaskCategory.learning,
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          due: _d(2026, 7, 5),
          tags: const ['architecture'],
          estimate: '1.5h',
          progress: 30,
          createdAt: _d(2026, 6, 27),
          dreamId: 'd1',
        ),
      ];

  static List<DreamModel> dreams() => [
        DreamModel(
          id: 'd1',
          title: 'Become a Software Architect',
          emoji: '🏛️',
          motivation: 'Design systems that outlive trends — build the technical judgment to lead at scale.',
          target: _d(2027, 12, 31),
          progress: 42,
          color: AppColors.indigo500,
          relatedTaskIds: const ['t12'],
        ),
        DreamModel(
          id: 'd2',
          title: 'Build My Startup',
          emoji: '🚀',
          motivation: 'Ship something people love and own my time. This is the long game.',
          target: _d(2028, 6, 30),
          progress: 27,
          color: AppColors.amber500,
          relatedTaskIds: const ['t5'],
        ),
        DreamModel(
          id: 'd3',
          title: 'Travel Japan',
          emoji: '🗾',
          motivation: 'Cherry blossoms in Kyoto, ramen in Osaka, quiet mornings at a ryokan.',
          target: _d(2026, 11, 15),
          progress: 58,
          color: AppColors.sky500,
          relatedTaskIds: const ['t11'],
        ),
        DreamModel(
          id: 'd4',
          title: 'Buy a House',
          emoji: '🏡',
          motivation: 'A calm, permanent space to build a life — and a studio corner for side projects.',
          target: _d(2029, 3, 1),
          progress: 15,
          color: AppColors.mint500,
        ),
      ];

  static List<NotificationModel> notifications() => const [
        NotificationModel(id: 'n1', title: 'Task due in 1 hour', body: '"Morning run — 5km" is due soon.', time: '10m ago', unread: true, type: NotificationType.reminder),
        NotificationModel(id: 'n2', title: 'Streak milestone!', body: "You've hit a 12-day streak. Keep it going.", time: '3h ago', unread: true, type: NotificationType.achievement),
        NotificationModel(id: 'n3', title: 'Dream progress updated', body: '"Travel Japan" moved to 58% complete.', time: '1d ago', type: NotificationType.dream),
        NotificationModel(id: 'n4', title: 'Weekly summary ready', body: 'You completed 28 of 44 tasks this week.', time: '2d ago', type: NotificationType.summary),
        NotificationModel(id: 'n5', title: 'New comment on a task', body: 'Tunde Bakare commented on "Finalize onboarding flow wireframes".', time: '2d ago', unread: true, type: NotificationType.comment),
        NotificationModel(id: 'n6', title: 'Task overdue', body: '"Review Q3 budget spreadsheet" is now overdue.', time: '2d ago', type: NotificationType.reminder),
        NotificationModel(id: 'n7', title: 'Badge earned: Consistency Champion', body: 'Your 30-day completion rate crossed 70%.', time: '3d ago', type: NotificationType.achievement),
        NotificationModel(id: 'n8', title: 'System update', body: 'Magadige Task now supports Dream Board reminders.', time: '5d ago', type: NotificationType.system),
      ];

  static List<BadgeModel> badges() => [
        BadgeModel(id: 'b1', label: '7-Day Streak', icon: Icons.local_fire_department_outlined, description: 'Complete at least one task every day for 7 days straight.', earned: true, earnedDate: _d(2026, 6, 20)),
        BadgeModel(id: 'b2', label: 'Early Bird', icon: Icons.wb_twilight_outlined, description: 'Complete a task before 8 AM.', earned: true, earnedDate: _d(2026, 6, 15)),
        BadgeModel(id: 'b3', label: 'Consistency Champion', icon: Icons.workspace_premium_outlined, description: 'Maintain a 30-day completion rate above 70%.', earned: true, earnedDate: _d(2026, 6, 30)),
        BadgeModel(id: 'b4', label: '100 Tasks Done', icon: Icons.emoji_events_outlined, description: 'Complete 100 tasks total.', progress: 78),
        BadgeModel(id: 'b5', label: 'Dream Achiever', icon: Icons.star_border_rounded, description: 'Reach 100% progress on any dream.', progress: 30),
        BadgeModel(id: 'b6', label: 'Night Owl', icon: Icons.nightlight_outlined, description: 'Complete a task after 10 PM.', earned: true, earnedDate: _d(2026, 6, 25)),
        BadgeModel(id: 'b7', label: 'Focus Master', icon: Icons.track_changes_outlined, description: 'Complete 20 high-priority tasks.', progress: 55),
        BadgeModel(id: 'b8', label: 'Planner', icon: Icons.calendar_month_outlined, description: 'Schedule tasks for every day in a week.', earned: true, earnedDate: _d(2026, 6, 10)),
      ];

  static List<ActivityModel> activity() => const [
        ActivityModel(id: 'a1', type: 'complete', text: 'Completed "Call mum"', time: '2h ago'),
        ActivityModel(id: 'a2', type: 'create', text: 'Added new task "Prepare investor update email"', time: '5h ago'),
        ActivityModel(id: 'a3', type: 'dream', text: 'Progressed "Travel Japan" dream +4%', time: '1d ago'),
        ActivityModel(id: 'a4', type: 'complete', text: 'Completed "Design system: audit color tokens"', time: '1d ago'),
        ActivityModel(id: 'a5', type: 'badge', text: 'Earned badge "Consistency Champion"', time: '2d ago'),
        ActivityModel(id: 'a6', type: 'overdue', text: '"Review Q3 budget spreadsheet" became overdue', time: '2d ago'),
      ];

  /// Completed vs. planned tasks per weekday, for the weekly bar chart.
  static const List<Map<String, int>> weeklyProgress = [
    {'completed': 5, 'total': 7},
    {'completed': 6, 'total': 6},
    {'completed': 3, 'total': 8},
    {'completed': 7, 'total': 7},
    {'completed': 4, 'total': 9},
    {'completed': 2, 'total': 4},
    {'completed': 1, 'total': 3},
  ];
  static const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const List<int> monthlyProgress = [62, 71, 55, 80, 74, 68, 85, 90, 77, 82, 95, 88];
  static const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static const List<Map<String, String>> quotes = [
    {'text': 'The best way to find yourself is to lose yourself in the service of others.', 'author': 'Mahatma Gandhi'},
    {'text': 'Any sufficiently advanced technology is indistinguishable from magic.', 'author': 'Arthur C. Clarke'},
    {'text': 'Stay hungry, stay foolish.', 'author': 'Steve Jobs'},
    {'text': "It always seems impossible until it's done.", 'author': 'Nelson Mandela'},
    {'text': 'It does not matter how slowly you go as long as you do not stop.', 'author': 'Confucius'},
    {'text': 'Simplicity is the ultimate sophistication.', 'author': 'Leonardo da Vinci'},
    {'text': 'Nothing in life is to be feared, it is only to be understood.', 'author': 'Marie Curie'},
    {'text': 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.', 'author': 'Aristotle'},
  ];
}
