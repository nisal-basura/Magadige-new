import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dream_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/user_repository.dart';

/// Wires the repository layer (currently all Mock* implementations backed
/// by [LocalDataStore]) and the app-wide theme. Swapping to a real backend
/// later means replacing the providers below with Api* implementations —
/// no Cubit or screen needs to change since they only depend on the
/// abstract repository interfaces.
class MagadigeApp extends StatelessWidget {
  const MagadigeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => MockAuthRepository()),
        RepositoryProvider<TaskRepository>(create: (_) => MockTaskRepository()),
        RepositoryProvider<DreamRepository>(create: (_) => MockDreamRepository()),
        RepositoryProvider<NotificationRepository>(create: (_) => MockNotificationRepository()),
        RepositoryProvider<UserRepository>(create: (_) => MockUserRepository()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final palette = themeState.isDark ? AppPalette.night : AppPalette.day;
          return MaterialApp.router(
            title: 'Magadige Task',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.from(palette, isDark: themeState.isDark),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
