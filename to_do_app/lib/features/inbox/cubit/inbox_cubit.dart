import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import 'unread_count_cubit.dart';

enum InboxFilter { all, unread, taskDue, badgeEarned, dreamProgress, system }

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
        return notifications.where((n) => n.isUnread).toList();
      case InboxFilter.taskDue:
        return notifications.where((n) => n.type == NotificationType.taskDue || n.type == NotificationType.streakReminder).toList();
      case InboxFilter.badgeEarned:
        return notifications.where((n) => n.type == NotificationType.badgeEarned).toList();
      case InboxFilter.dreamProgress:
        return notifications.where((n) => n.type == NotificationType.dreamProgress).toList();
      case InboxFilter.system:
        return notifications.where((n) => n.type == NotificationType.system).toList();
    }
  }

  List<NotificationModel> get unreadOnes => filtered.where((n) => n.isUnread).toList();
  List<NotificationModel> get readOnes => filtered.where((n) => !n.isUnread).toList();

  InboxState copyWith({FormStatus? status, List<NotificationModel>? notifications, InboxFilter? filter}) {
    return InboxState(status: status ?? this.status, notifications: notifications ?? this.notifications, filter: filter ?? this.filter);
  }

  @override
  List<Object?> get props => [status, notifications, filter];
}

class InboxCubit extends Cubit<InboxState> {
  final NotificationRepository _repository;
  final UnreadCountCubit _unreadCountCubit;

  InboxCubit(this._repository, this._unreadCountCubit) : super(const InboxState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final notifications = await _repository.fetchNotifications();
      emit(state.copyWith(status: FormStatus.success, notifications: notifications));
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }
  }

  void setFilter(InboxFilter f) => emit(state.copyWith(filter: f));

  Future<void> markRead(String id) async {
    await _repository.markRead(id);
    emit(state.copyWith(notifications: state.notifications.map((n) => n.id == id ? n.copyWith(isUnread: false) : n).toList()));
    _unreadCountCubit.refresh();
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    emit(state.copyWith(notifications: state.notifications.map((n) => n.copyWith(isUnread: false)).toList()));
    _unreadCountCubit.refresh();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    emit(state.copyWith(notifications: state.notifications.where((n) => n.id != id).toList()));
    _unreadCountCubit.refresh();
  }
}
