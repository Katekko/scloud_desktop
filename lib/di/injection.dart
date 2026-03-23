import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/auth_cubit.dart';
import '../features/auth/auth_repository.dart';
import '../features/billing/billing_cubit.dart';
import '../features/database/database_cubit.dart';
import '../features/domains/domains_cubit.dart';
import '../features/env_vars/env_vars_cubit.dart';
import '../features/logs/container_logs_cubit.dart';
import '../features/logs/deploy_build_log_cubit.dart';
import '../features/profile/profile_cubit.dart';
import '../features/projects/project_list_cubit.dart';
import '../features/projects/project_repository.dart';
import '../features/secrets/secrets_cubit.dart';
import '../features/status/status_cubit.dart';
import '../features/users/users_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Notifier that triggers go_router refresh when [AuthCubit] state changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}

/// Configures dependency injection. Call from [main] before [runApp].
Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<AuthRepository>(AuthRepository.new)
    ..registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerLazySingleton<AuthRefreshNotifier>(
      () => AuthRefreshNotifier(getIt<AuthCubit>()),
    )
    ..registerLazySingleton<ProjectRepository>(ProjectRepository.new)
    ..registerLazySingleton<ProjectListCubit>(
      () => ProjectListCubit(getIt<ProjectRepository>()),
    )
    ..registerLazySingleton<StatusCubit>(
      () => StatusCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<ContainerLogsCubit>(
      () => ContainerLogsCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<DeployBuildLogCubit>(
      () => DeployBuildLogCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<EnvVarsCubit>(
      () => EnvVarsCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<SecretsCubit>(
      () => SecretsCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<DomainsCubit>(
      () => DomainsCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<DatabaseCubit>(
      () => DatabaseCubit(getIt<ProjectRepository>()),
    )
    ..registerFactory<UsersCubit>(() => UsersCubit(getIt<ProjectRepository>()))
    ..registerFactory<ProfileCubit>(ProfileCubit.new)
    ..registerFactory<BillingCubit>(BillingCubit.new);

  getIt<AuthCubit>().restoreSession();
}
