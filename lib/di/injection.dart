import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/auth_cubit.dart';
import '../features/auth/auth_repository.dart';

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
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<AuthRefreshNotifier>(
      () => AuthRefreshNotifier(getIt<AuthCubit>()),
    );

  getIt<AuthCubit>().restoreSession();
}
