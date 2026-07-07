import '../models/badge_model.dart';
import '../models/category_model.dart';
import '../models/dream_model.dart';
import '../models/notification_model.dart';
import '../models/subtask_model.dart';
import '../models/tag_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

/// Static seed/demo data backing the Mock*Repository implementations used
/// before a real backend is wired up (kept around for offline dev/tests —
/// the live app talks to Api*Repository instead). Shapes mirror the real
/// API's models exactly so swapping between them is transparent to Cubits.
class SeedData {
  SeedData._();

  static DateTime _d(int y, int m, int d) => DateTime(y, m, d);

  static const categories = [
    CategoryModel(id: 'work', label: 'Work', colorRaw: '#3B82F6', iconRaw: 'briefcase'),
    CategoryModel(id: 'personal', label: 'Personal', colorRaw: '#8B5CF6', iconRaw: 'user'),
    CategoryModel(id: 'health', label: 'Health', colorRaw: '#10B981', iconRaw: 'heart'),
    CategoryModel(id: 'study', label: 'Study', colorRaw: '#F59E0B', iconRaw: 'book'),
    CategoryModel(id: 'finance', label: 'Finance', colorRaw: '#EF4444', iconRaw: 'dollar-sign'),
    CategoryModel(id: 'home', label: 'Home', colorRaw: '#06B6D4', iconRaw: 'home'),
  ];

  static CategoryModel _cat(String id) => categories.firstWhere((c) => c.id == id);

  static final UserModel user = UserModel(
    id: 1,
    name: 'Amaka Nwosu',
    email: 'nbcodezone@gmail.com',
    role: 'user',
    plan: 'Pro',
    headline: 'Product Designer @ Northwind Labs',
    timezone: 'GMT+1 · Lagos',
    streakCurrent: 12,
    streakLongest: 34,
    productivityScore: 87,
    createdAt: _d(2024, 3, 1),
  );

  static List<TagModel> tags() => const [
        TagModel(id: '1', label: 'design'),
        TagModel(id: '2', label: 'fitness'),
        TagModel(id: '3', label: 'budget'),
      ];

  static List<SubtaskModel> subtasksFor(String taskId) => [
        SubtaskModel(id: '${taskId}s1', taskId: taskId, title: 'Research & plan approach', isDone: true, position: 0),
        SubtaskModel(id: '${taskId}s2', taskId: taskId, title: 'Execute the core work', isDone: true, position: 1),
        SubtaskModel(id: '${taskId}s3', taskId: taskId, title: 'Review with a peer', isDone: false, position: 2),
        SubtaskModel(id: '${taskId}s4', taskId: taskId, title: 'Polish & finalize', isDone: false, position: 3),
      ];

  static List<TaskModel> tasks() => [
        TaskModel(
          id: 't1',
          title: 'Finalize onboarding flow wireframes',
          description: 'Polish the 5-step onboarding wireframes and prep for the Friday design crit with the growth team.',
          category: _cat('work'),
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          due: _d(2026, 7, 2),
          tags: [tags()[0]],
          estimateMinutes: 180,
          favorite: true,
          createdAt: _d(2026, 6, 28),
          subtasks: subtasksFor('t1'),
        ),
        TaskModel(
          id: 't2',
          title: 'Morning run — 5km',
          description: 'Easy pace, focus on breathing rhythm.',
          category: _cat('health'),
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          due: _d(2026, 7, 2),
          tags: [tags()[1]],
          estimateMinutes: 40,
          createdAt: _d(2026, 6, 30),
        ),
        TaskModel(
          id: 't3',
          title: 'Review Q3 budget spreadsheet',
          description: 'Cross-check marketing spend against approved budget lines before the finance sync.',
          category: _cat('finance'),
          priority: TaskPriority.high,
          status: TaskStatus.overdue,
          due: _d(2026, 6, 30),
          tags: [tags()[2]],
          estimateMinutes: 60,
          createdAt: _d(2026, 6, 25),
        ),
        TaskModel(
          id: 't4',
          title: "Read 'Deep Work' — Ch. 4",
          description: 'Continue reading, take notes for the book club discussion.',
          category: _cat('study'),
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          due: _d(2026, 7, 3),
          estimateMinutes: 45,
          createdAt: _d(2026, 6, 29),
        ),
        TaskModel(
          id: 't5',
          title: 'Prepare investor update email',
          description: 'Summarize product milestones and MRR growth for the monthly investor newsletter.',
          category: _cat('work'),
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          due: _d(2026, 7, 4),
          estimateMinutes: 120,
          favorite: true,
          createdAt: _d(2026, 7, 1),
          dreamId: 'd2',
        ),
        TaskModel(
          id: 't6',
          title: 'Grocery run for the week',
          description: 'Get produce, oats, and coffee beans.',
          category: _cat('personal'),
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          due: _d(2026, 7, 1),
          estimateMinutes: 30,
          createdAt: _d(2026, 6, 27),
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
          colorRaw: '#6366F1',
          tasksCount: 3,
          completedTasksCount: 1,
        ),
        DreamModel(
          id: 'd2',
          title: 'Build My Startup',
          emoji: '🚀',
          motivation: 'Ship something people love and own my time. This is the long game.',
          target: _d(2028, 6, 30),
          progress: 27,
          colorRaw: '#F59E0B',
          tasksCount: 4,
          completedTasksCount: 1,
        ),
        DreamModel(
          id: 'd3',
          title: 'Travel Japan',
          emoji: '🗾',
          motivation: 'Cherry blossoms in Kyoto, ramen in Osaka, quiet mornings at a ryokan.',
          target: _d(2026, 11, 15),
          progress: 58,
          colorRaw: '#0EA5E9',
          tasksCount: 2,
          completedTasksCount: 1,
        ),
        DreamModel(
          id: 'd4',
          title: 'Buy a House',
          emoji: '🏡',
          motivation: 'A calm, permanent space to build a life — and a studio corner for side projects.',
          target: _d(2029, 3, 1),
          progress: 15,
          colorRaw: '#10B981',
        ),
      ];

  static List<NotificationModel> notifications() => [
        NotificationModel(id: 'n1', title: 'Task due in 1 hour', body: '"Morning run — 5km" is due soon.', createdAt: DateTime.now().subtract(const Duration(minutes: 10)), isUnread: true, type: NotificationType.taskDue),
        NotificationModel(id: 'n2', title: 'Streak milestone!', body: "You've hit a 12-day streak. Keep it going.", createdAt: DateTime.now().subtract(const Duration(hours: 3)), isUnread: true, type: NotificationType.streakReminder),
        NotificationModel(id: 'n3', title: 'Dream progress updated', body: '"Travel Japan" moved to 58% complete.', createdAt: DateTime.now().subtract(const Duration(days: 1)), type: NotificationType.dreamProgress),
        NotificationModel(id: 'n4', title: 'Badge earned: Consistency Champion', body: 'Your 30-day completion rate crossed 70%.', createdAt: DateTime.now().subtract(const Duration(days: 3)), type: NotificationType.badgeEarned),
        NotificationModel(id: 'n5', title: 'System update', body: 'Magadige Task now supports Dream Board reminders.', createdAt: DateTime.now().subtract(const Duration(days: 5)), type: NotificationType.system),
      ];

  static List<BadgeModel> badges() => const [
        BadgeModel(id: 'streak_7', label: 'Week Warrior', iconRaw: 'flame', description: 'Maintain a 7-day streak.'),
        BadgeModel(id: 'early_bird', label: 'Early Bird', iconRaw: 'sunrise', description: 'Complete a task before 7am.'),
        BadgeModel(id: 'streak_30', label: 'Consistency Champion', iconRaw: 'trophy', description: 'Maintain a 30-day streak.'),
        BadgeModel(id: 'hundred_tasks', label: 'Centurion', iconRaw: 'medal', description: 'Complete 100 tasks.'),
        BadgeModel(id: 'first_task', label: 'Getting Started', iconRaw: 'star', description: 'Complete your first task.'),
      ];

  static List<UserBadgeModel> userBadges() => [
        UserBadgeModel(badge: badges()[0], earned: true, earnedDate: _d(2026, 6, 20), progress: 100),
        UserBadgeModel(badge: badges()[1], earned: true, earnedDate: _d(2026, 6, 15), progress: 100),
        UserBadgeModel(badge: badges()[2], earned: true, earnedDate: _d(2026, 6, 30), progress: 100),
        UserBadgeModel(badge: badges()[3], progress: 78),
        UserBadgeModel(badge: badges()[4], earned: true, earnedDate: _d(2026, 6, 10), progress: 100),
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
