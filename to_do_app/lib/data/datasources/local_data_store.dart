import '../models/badge_model.dart';
import '../models/dream_model.dart';
import '../models/notification_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'seed_data.dart';

/// In-memory app state shared by every Mock*Repository, seeded from
/// [SeedData]. This stands in for a local database / cache layer — when a
/// real backend is wired up, repositories talk to an ApiClient instead and
/// this class goes away without any Cubit or UI code changing, since they
/// only ever depend on the repository *interfaces*.
///
/// Singleton so all mock repositories (and therefore all Cubits) observe the
/// same data during a session — e.g. completing a task on the Dashboard is
/// reflected immediately on the Tasks and Analytics screens.
class LocalDataStore {
  LocalDataStore._internal()
      : user = SeedData.user,
        tasks = SeedData.tasks(),
        dreams = SeedData.dreams(),
        notifications = SeedData.notifications(),
        badges = SeedData.badges(),
        activity = List.of(SeedData.activity());

  static final LocalDataStore instance = LocalDataStore._internal();

  UserModel user;
  List<TaskModel> tasks;
  List<DreamModel> dreams;
  List<NotificationModel> notifications;
  List<BadgeModel> badges;
  List<ActivityModel> activity;

  void reset() {
    user = SeedData.user;
    tasks = SeedData.tasks();
    dreams = SeedData.dreams();
    notifications = SeedData.notifications();
    badges = SeedData.badges();
    activity = List.of(SeedData.activity());
  }
}
