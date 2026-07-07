import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/session_cubit.dart';
import 'core/network/api_client.dart';
import 'core/network/token_storage.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/dream_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/quote_repository.dart';
import 'data/repositories/subtask_repository.dart';
import 'data/repositories/tag_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/categories/cubit/categories_cubit.dart';
import 'features/inbox/cubit/unread_count_cubit.dart';

/// Wires the repository layer (all Api* implementations talking to the real
/// backend — see `lib/core/network/api_config.dart` for the host) and the
/// app-wide session/theme/category state. A [StatefulWidget] so the whole
/// dependency graph (HTTP client, repositories, router) is built exactly
/// once in [initState] rather than being rebuilt on every widget rebuild,
/// while the widget itself stays a plain zero-arg `MagadigeApp()` for the
/// existing smoke test.
class MagadigeApp extends StatefulWidget {
  const MagadigeApp({super.key});

  @override
  State<MagadigeApp> createState() => _MagadigeAppState();
}

class _MagadigeAppState extends State<MagadigeApp> {
  late final TokenStorage _tokenStorage;
  late final SessionCubit _sessionCubit;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final TaskRepository _taskRepository;
  late final SubtaskRepository _subtaskRepository;
  late final TagRepository _tagRepository;
  late final DreamRepository _dreamRepository;
  late final NotificationRepository _notificationRepository;
  late final UserRepository _userRepository;
  late final CategoryRepository _categoryRepository;
  late final QuoteRepository _quoteRepository;
  late final CategoriesCubit _categoriesCubit;
  late final UnreadCountCubit _unreadCountCubit;
  late final GoRouter _router;
  late final StreamSubscription<SessionState> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _sessionCubit = SessionCubit();
    _apiClient = ApiClient(tokenStorage: _tokenStorage, onSessionExpired: _sessionCubit.setUnauthenticated);
    _authRepository = ApiAuthRepository(apiClient: _apiClient, tokenStorage: _tokenStorage);
    _taskRepository = ApiTaskRepository(_apiClient);
    _subtaskRepository = ApiSubtaskRepository(_apiClient);
    _tagRepository = ApiTagRepository(_apiClient);
    _dreamRepository = ApiDreamRepository(_apiClient);
    _notificationRepository = ApiNotificationRepository(_apiClient);
    _userRepository = ApiUserRepository(_apiClient);
    _categoryRepository = ApiCategoryRepository(_apiClient);
    _quoteRepository = ApiQuoteRepository(_apiClient);
    _categoriesCubit = CategoriesCubit(_categoryRepository);
    _unreadCountCubit = UnreadCountCubit(_notificationRepository);
    _router = buildAppRouter(_sessionCubit);
    // Categories/unread-count both require auth — load them once the
    // session is actually authenticated rather than at construction time
    // (registered before bootstrap() so it catches that first resolution too).
    _sessionSubscription = _sessionCubit.stream.listen((state) {
      if (state.status == SessionStatus.authenticated) {
        _categoriesCubit.load();
        _unreadCountCubit.refresh();
      } else if (state.status == SessionStatus.unauthenticated) {
        _unreadCountCubit.reset();
      }
    });
    _sessionCubit.bootstrap(_authRepository);
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    _sessionCubit.close();
    _categoriesCubit.close();
    _unreadCountCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<TaskRepository>.value(value: _taskRepository),
        RepositoryProvider<SubtaskRepository>.value(value: _subtaskRepository),
        RepositoryProvider<TagRepository>.value(value: _tagRepository),
        RepositoryProvider<DreamRepository>.value(value: _dreamRepository),
        RepositoryProvider<NotificationRepository>.value(value: _notificationRepository),
        RepositoryProvider<UserRepository>.value(value: _userRepository),
        RepositoryProvider<QuoteRepository>.value(value: _quoteRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _sessionCubit),
          BlocProvider<CategoriesCubit>.value(value: _categoriesCubit),
          BlocProvider<UnreadCountCubit>.value(value: _unreadCountCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final palette = themeState.isDark ? AppPalette.night : AppPalette.day;
            return MaterialApp.router(
              title: 'Magadige Task',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.from(palette, isDark: themeState.isDark),
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
