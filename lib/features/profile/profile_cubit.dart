import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import 'package:scloud_desktop/shared/app_logger.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileLoading()) {
    _logger = CommandLogger(AppLogger());
    _globalConfig = GlobalConfiguration.resolve(args: [], env: {});
    _logger.configuration = _globalConfig;
  }

  late final CommandLogger _logger;
  late final GlobalConfiguration _globalConfig;

  Future<void> load() async {
    emit(const ProfileLoading());
    final provider = CloudCliServiceProvider();
    provider.initialize(globalConfiguration: _globalConfig, logger: _logger);

    try {
      final user = await provider.cloudApiClient.users.readUser();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      AppDebug.logError('ProfileCubit', 'load error: $e');
      emit(ProfileError(e.toString()));
    } finally {
      provider.shutdown();
    }
  }
}
