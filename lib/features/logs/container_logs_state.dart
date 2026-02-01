import 'package:ground_control_client/ground_control_client.dart';

/// State for the container logs screen.
sealed class ContainerLogsState {
  const ContainerLogsState();
}

/// Initial or loading (stream not yet started).
final class ContainerLogsLoading extends ContainerLogsState {
  const ContainerLogsLoading();
}

/// Streaming records (list grows as new records arrive).
final class ContainerLogsStreaming extends ContainerLogsState {
  const ContainerLogsStreaming(this.records);

  final List<LogRecord> records;
}

/// Error while tailing.
final class ContainerLogsError extends ContainerLogsState {
  const ContainerLogsError(this.message);

  final String message;
}
