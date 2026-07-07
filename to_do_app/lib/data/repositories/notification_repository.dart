import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> delete(String id);

  Future<int> getUnreadCount();
}

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    final items = await _api.getAllPages('/notifications');
    return items.map(NotificationModel.fromJson).toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _api.patch('/notifications/read-all');
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/notifications/$id');
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await _api.get('/notifications', query: const {'per_page': 1}) as Map<String, dynamic>;
    return data['unread_count'] as int? ?? 0;
  }
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
    _store.notifications = _store.notifications.map((n) => n.id == id ? n.copyWith(isUnread: false) : n).toList();
  }

  @override
  Future<void> markAllRead() async {
    _store.notifications = _store.notifications.map((n) => n.copyWith(isUnread: false)).toList();
  }

  @override
  Future<void> delete(String id) async {
    _store.notifications = _store.notifications.where((n) => n.id != id).toList();
  }

  @override
  Future<int> getUnreadCount() async => _store.notifications.where((n) => n.isUnread).length;
}
