import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState extends Equatable {
  final SessionStatus status;
  final UserModel? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  @override
  List<Object?> get props => [status, user];
}

/// App-wide source of truth for "are we logged in". Seeded once at startup
/// from whatever [AuthRepository.currentUser] resolves to (a cached user
/// read from secure storage for a fast boot, or null if there's no session),
/// then flipped reactively: to `authenticated` on login/register, to
/// `unauthenticated` on logout or when [ApiClient] detects the session was
/// rejected server-side. `app_router.dart`'s redirect logic listens to this
/// via [GoRouterRefreshStream].
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  Future<void> bootstrap(AuthRepository authRepository) async {
    try {
      final user = await authRepository.currentUser();
      emit(user != null ? SessionState(status: SessionStatus.authenticated, user: user) : const SessionState(status: SessionStatus.unauthenticated));
    } catch (_) {
      emit(const SessionState(status: SessionStatus.unauthenticated));
    }
  }

  void setAuthenticated(UserModel user) => emit(SessionState(status: SessionStatus.authenticated, user: user));

  void setUnauthenticated() => emit(const SessionState(status: SessionStatus.unauthenticated));

  void updateUser(UserModel user) {
    if (state.status == SessionStatus.authenticated) emit(SessionState(status: state.status, user: user));
  }
}
