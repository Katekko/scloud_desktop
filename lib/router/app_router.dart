import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../features/auth/auth_cubit.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/login_waiting_screen.dart';
import '../features/projects/project_list_cubit.dart';
import '../features/projects/project_list_screen.dart';
import '../features/status/status_cubit.dart';
import '../features/status/status_screen.dart';

/// Route paths.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String loginWaiting = '/login-waiting';
  static const String home = '/home';
  static const String status = '/status';
}

/// Registers [GoRouter] with get_it and must be called after [configureDependencies].
void initRouter() {
  getIt.registerLazySingleton<GoRouter>(() => createAppRouter());
}

/// Builds the app [GoRouter]. Depends on [configureDependencies] having been called.
GoRouter createAppRouter() {
  final cubit = getIt<AuthCubit>();
  final refreshNotifier = getIt<AuthRefreshNotifier>();

  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation: AppRoutes.login,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = cubit.state;
      final path = state.uri.path;

      if (authState is Unauthenticated && path != AppRoutes.login) {
        return AppRoutes.login;
      }
      if (authState is LoginInProgress && path != AppRoutes.loginWaiting) {
        return AppRoutes.loginWaiting;
      }
      if (authState is Authenticated &&
          path != AppRoutes.home &&
          path != AppRoutes.status) {
        return AppRoutes.home;
      }
      if (authState is AuthError) {
        final message = authState.message;
        if (path != AppRoutes.login) {
          return '${AppRoutes.login}?error=$message';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          final error = state.uri.queryParameters['error'];
          return LoginScreen(cubit: cubit, errorMessage: error);
        },
      ),
      GoRoute(
        path: AppRoutes.loginWaiting,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginWaitingScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) {
          final authState = cubit.state;
          if (authState is! Authenticated) {
            return const SizedBox.shrink();
          }
          return ProjectListScreen(
            cubit: getIt<ProjectListCubit>(),
            authCubit: cubit,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.status,
        builder: (BuildContext context, GoRouterState state) {
          final authState = cubit.state;
          if (authState is! Authenticated) {
            return const SizedBox.shrink();
          }
          return StatusScreen(cubit: getIt<StatusCubit>());
        },
      ),
    ],
  );
}
