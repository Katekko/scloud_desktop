import 'package:ground_control_client/ground_control_client.dart';

sealed class BillingState {
  const BillingState();
}

final class BillingLoading extends BillingState {
  const BillingLoading();
}

final class BillingLoaded extends BillingState {
  const BillingLoaded({
    required this.subscriptionInfo,
    required this.paymentMethods,
    required this.planNames,
  });

  final SubscriptionInfo subscriptionInfo;
  final List<PaymentMethod> paymentMethods;
  final List<String> planNames;
}

final class BillingError extends BillingState {
  const BillingError(this.message);

  final String message;
}
