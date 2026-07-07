import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notification_repository.dart';

/// App-wide unread notification count backing the bell badge on
/// [AppScaffold] — separate from [InboxCubit] (which is route-local to the
/// Inbox screen) since the badge needs to be visible from every screen.
/// Deliberately does *not* refresh in its constructor — `/notifications`
/// requires auth, so hitting it eagerly at app startup (before the session
/// is known) would just 401. `MagadigeApp` triggers [refresh] once
/// [SessionCubit] reports `authenticated`.
class UnreadCountCubit extends Cubit<int> {
  final NotificationRepository _repository;

  UnreadCountCubit(this._repository) : super(0);

  Future<void> refresh() async {
    try {
      emit(await _repository.getUnreadCount());
    } catch (_) {
      // Leave the last known count on failure.
    }
  }

  void reset() => emit(0);
}
