import '../datasources/local_data_store.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> delete(String id);
}

class MockNotificationRepository implements NotificationRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.notifications);
  }

  @override
  Future<void> markRead(String id) async {
    _store.notifications =
        _store.notifications.map((n) => n.id == id ? n.copyWith(unread: false) : n).toList();
  }

  @override
  Future<void> markAllRead() async {
    _store.notifications = _store.notifications.map((n) => n.copyWith(unread: false)).toList();
  }

  @override
  Future<void> delete(String id) async {
    _store.notifications = _store.notifications.where((n) => n.id != id).toList();
  }
}
