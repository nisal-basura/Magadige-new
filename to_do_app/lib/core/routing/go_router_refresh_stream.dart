import 'dart:async';

import 'package:flutter/foundation.dart';

/// Standard adapter so go_router's `refreshListenable` can react to a Cubit
/// stream (here, [SessionCubit]) instead of a bare [ChangeNotifier].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
