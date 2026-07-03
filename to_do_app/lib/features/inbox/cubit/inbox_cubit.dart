import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

enum InboxFilter { all, unread, reminder, achievement, dream, system }

class InboxState extends Equatable {
  final FormStatus status;
  final List<NotificationModel> notifications;
  final InboxFilter filter;

  const InboxState({this.status = FormStatus.initial, this.notifications = const [], this.filter = InboxFilter.all});

  List<NotificationModel> get filtered {
    switch (filter) {
      case InboxFilter.all:
        return notifications;
      case InboxFilter.unread:
        return notifications.where((n) => n.unread).toList();
      case InboxFilter.reminder:
        return notifications.where((n) => n.type == NotificationType.reminder).toList();
      case InboxFilter.achievement:
        return notifications.where((n) => n.type == NotificationType.achievement).toList();
      case InboxFilter.dream:
        return notifications.where((n) => n.type == NotificationType.dream).toList();
      case InboxFilter.system:
        return notifications.where((n) => n.type == NotificationType.system).toList();
    }
  }

  List<NotificationModel> get unreadOnes => filtered.where((n) => n.unread).toList();
  List<NotificationModel> get readOnes => filtered.where((n) => !n.unread).toList();

  InboxState copyWith({FormStatus? status, List<NotificationModel>? notifications, InboxFilter? filter}) {
    return InboxState(status: status ?? this.status, notifications: notifications ?? this.notifications, filter: filter ?? this.filter);
  }

  @override
  List<Object?> get props => [status, notifications, filter];
}

class InboxCubit extends Cubit<InboxState> {
  final NotificationRepository _repository;

  InboxCubit(this._repository) : super(const InboxState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final notifications = await _repository.fetchNotifications();
    emit(state.copyWith(status: FormStatus.success, notifications: notifications));
  }

  void setFilter(InboxFilter f) => emit(state.copyWith(filter: f));

  Future<void> markRead(String id) async {
    await _repository.markRead(id);
    emit(state.copyWith(notifications: state.notifications.map((n) => n.id == id ? n.copyWith(unread: false) : n).toList()));
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    emit(state.copyWith(notifications: state.notifications.map((n) => n.copyWith(unread: false)).toList()));
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    emit(state.copyWith(notifications: state.notifications.where((n) => n.id != id).toList()));
  }
}
