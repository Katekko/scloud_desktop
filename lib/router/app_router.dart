import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../features/auth/auth_cubit.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/login_waiting_screen.dart';
import '../features/billing/billing_cubit.dart';
import '../features/billing/billing_screen.dart';
import '../features/database/database_cubit.dart';
import '../features/database/database_screen.dart';
import '../features/domains/domains_cubit.dart';
import '../features/domains/domains_screen.dart';
import '../features/env_vars/env_vars_cubit.dart';
import '../features/env_vars/env_vars_screen.dart';
import '../features/logs/container_logs_cubit.dart';
import '../features/logs/container_logs_screen.dart';
import '../features/logs/deploy_build_log_cubit.dart';
import '../features/logs/deploy_build_log_screen.dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_screen.dart';
import '../features/projects/project_list_cubit.dart';
import '../features/projects/project_list_screen.dart';
import '../features/secrets/secrets_cubit.dart';
import '../features/secrets/secrets_screen.dart';
import '../features/status/status_cubit.dart';
import '../features/status/status_screen.dart';
import '../features/users/users_cubit.dart';
import '../features/users/users_screen.dart';

/// Route paths.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String loginWaiting = '/login-waiting';
  static const String home = '/home';
  static const String status = '/status';
  static const String deployLog = '/deploy-log';
  static const String containerLogs = '/container-logs';
  static const String envVars = '/env-vars';
  static const String secrets = '/secrets';
  static const String domains = '/domains';
  static const String database = '/database';
  static const String users = '/users';
  static const String profile = '/profile';
  static const String billing = '/billing';
}

/// All authenticated routes.
const _authenticatedRoutes = [
  AppRoutes.home,
  AppRoutes.status,
  AppRoutes.deployLog,
  AppRoutes.containerLogs,
  AppRoutes.envVars,
  AppRoutes.secrets,
  AppRoutes.domains,
  AppRoutes.database,
  AppRoutes.users,
  AppRoutes.profile,
  AppRoutes.billing,
];

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
      if (authState is Authenticated && !_authenticatedRoutes.contains(path)) {
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
      GoRoute(
        path: AppRoutes.deployLog,
        builder: (BuildContext context, GoRouterState state) {
          final args = DeployBuildLogScreen.argsFromExtra(state.extra);
          if (args == null) {
            return const SizedBox.shrink();
          }
          final cubit = getIt<DeployBuildLogCubit>();
          cubit.load(args.projectId, args.attemptId);
          return BlocProvider.value(
            value: cubit,
            child: DeployBuildLogScreen(
              projectId: args.projectId,
              attemptId: args.attemptId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.containerLogs,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = ContainerLogsScreen.projectIdFromExtra(state.extra);
          if (projectId == null) {
            return const SizedBox.shrink();
          }
          final cubit = getIt<ContainerLogsCubit>();
          cubit.startTailing(projectId);
          return BlocProvider.value(
            value: cubit,
            child: ContainerLogsScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.envVars,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = EnvVarsScreen.projectIdFromExtra(state.extra);
          if (projectId == null) return const SizedBox.shrink();
          final cubit = getIt<EnvVarsCubit>();
          cubit.load(projectId);
          return BlocProvider.value(
            value: cubit,
            child: EnvVarsScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.secrets,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = SecretsScreen.projectIdFromExtra(state.extra);
          if (projectId == null) return const SizedBox.shrink();
          final cubit = getIt<SecretsCubit>();
          cubit.load(projectId);
          return BlocProvider.value(
            value: cubit,
            child: SecretsScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.domains,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = DomainsScreen.projectIdFromExtra(state.extra);
          if (projectId == null) return const SizedBox.shrink();
          final cubit = getIt<DomainsCubit>();
          cubit.load(projectId);
          return BlocProvider.value(
            value: cubit,
            child: DomainsScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.database,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = DatabaseScreen.projectIdFromExtra(state.extra);
          if (projectId == null) return const SizedBox.shrink();
          final cubit = getIt<DatabaseCubit>();
          cubit.load(projectId);
          return BlocProvider.value(
            value: cubit,
            child: DatabaseScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = UsersScreen.projectIdFromExtra(state.extra);
          if (projectId == null) return const SizedBox.shrink();
          final cubit = getIt<UsersCubit>();
          cubit.load(projectId);
          return BlocProvider.value(
            value: cubit,
            child: UsersScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => getIt<ProfileCubit>(),
            child: const ProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.billing,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => getIt<BillingCubit>(),
            child: const BillingScreen(),
          );
        },
      ),
    ],
  );
}
