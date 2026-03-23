import 'package:ground_control_client/ground_control_client.dart';

sealed class DomainsState {
  const DomainsState();
}

final class DomainsLoading extends DomainsState {
  const DomainsLoading();
}

final class DomainsLoaded extends DomainsState {
  const DomainsLoaded({required this.projectId, required this.domainList});

  final String projectId;
  final CustomDomainNameList domainList;
}

final class DomainsError extends DomainsState {
  const DomainsError(this.message);

  final String message;
}

final class DomainsOperationInProgress extends DomainsState {
  const DomainsOperationInProgress({
    required this.projectId,
    required this.domainList,
  });

  final String projectId;
  final CustomDomainNameList domainList;
}
