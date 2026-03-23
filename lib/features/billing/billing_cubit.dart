import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import 'package:scloud_desktop/shared/app_logger.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  BillingCubit() : super(const BillingLoading()) {
    _logger = CommandLogger(AppLogger());
    _globalConfig = GlobalConfiguration.resolve(args: [], env: {});
    _logger.configuration = _globalConfig;
  }

  late final CommandLogger _logger;
  late final GlobalConfiguration _globalConfig;

  Future<void> load() async {
    emit(const BillingLoading());
    final provider = CloudCliServiceProvider();
    provider.initialize(globalConfiguration: _globalConfig, logger: _logger);

    try {
      final results = await Future.wait([
        provider.cloudApiClient.plans.getSubscriptionInfo(),
        provider.cloudApiClient.billing.listPaymentMethods(),
        provider.cloudApiClient.plans.listProcuredPlanNames(),
      ]);

      emit(
        BillingLoaded(
          subscriptionInfo: results[0] as dynamic,
          paymentMethods: results[1] as dynamic,
          planNames: results[2] as dynamic,
        ),
      );
    } catch (e) {
      AppDebug.logError('BillingCubit', 'load error: $e');
      emit(BillingError(e.toString()));
    } finally {
      provider.shutdown();
    }
  }
}
