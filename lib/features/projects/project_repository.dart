import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart' hide Project;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';

import 'package:scloud_desktop/shared/app_logger.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'project.dart';
import 'project_status.dart';

/// Repository for project list and status using serverpod_cloud_cli.
///
/// Uses CloudCliServiceProvider (same auth storage as scloud CLI).
class ProjectRepository {
  ProjectRepository() {
    _logger = CommandLogger(AppLogger());
    _globalConfig = GlobalConfiguration.resolve(args: [], env: {});
    _logger.configuration = _globalConfig;
  }

  late final CommandLogger _logger;
  late final GlobalConfiguration _globalConfig;

  /// Fetches the list of projects for the current user.
  ///
  /// Returns projects with linked status based on project config in
  /// [linkedProjectDirectory] if provided.
  Future<List<Project>> fetchProjectList({
    String? linkedProjectDirectory,
  }) async {
    final provider = CloudCliServiceProvider();
    provider.initialize(globalConfiguration: _globalConfig, logger: _logger);

    try {
      final client = provider.cloudApiClient;
      final projects = await client.projects.listProjectsInfo(
        includeLatestDeployAttemptTime: true,
      );

      final linkedIds = <String>{};
      if (linkedProjectDirectory != null) {
        final config = _tryReadConfigFromDirectory(linkedProjectDirectory);
        if (config != null && config.projectId.isNotEmpty) {
          linkedIds.add(config.projectId);
        }
      }
      final configFile = _globalConfig.projectConfigFile;
      if (configFile != null) {
        final config = ScloudConfigIO.readFromFile(configFile.path);
        if (config != null && config.projectId.isNotEmpty) {
          linkedIds.add(config.projectId);
        }
      }

      final active =
          projects.where((p) => p.project.archivedAt == null).toList()..sort(
            (a, b) => a.project.createdAt.compareTo(b.project.createdAt),
          );

      return active
          .map(
            (p) => Project(
              id: p.project.cloudProjectId,
              displayName: p.project.cloudProjectId,
              isLinked: linkedIds.contains(p.project.cloudProjectId),
            ),
          )
          .toList();
    } on FailureException catch (e) {
      AppDebug.logError(
        'ProjectRepository',
        'fetchProjectList failed: ${e.reason}',
      );
      rethrow;
    } catch (e) {
      AppDebug.logError('ProjectRepository', 'fetchProjectList error: $e');
      rethrow;
    } finally {
      provider.shutdown();
    }
  }

  /// Fetches status and deploy history for the given project.
  ///
  /// Uses [projectId] as cloudCapsuleId (standard for Serverpod Cloud).
  /// [deployLimit] limits how many deploy attempts to return (default 20).
  Future<({ProjectStatus status, List<DeployAttemptInfo> deployAttempts})>
  fetchProjectDetails(String projectId, {int deployLimit = 20}) async {
    final provider = CloudCliServiceProvider();
    provider.initialize(globalConfiguration: _globalConfig, logger: _logger);

    try {
      final client = provider.cloudApiClient;
      final attempts = await StatusFeature.getDeployAttemptList(
        client,
        cloudCapsuleId: projectId,
        limit: deployLimit,
      );

      final deployAttempts = attempts
          .map(
            (a) => DeployAttemptInfo(
              id: a.attemptId,
              status: _deploymentStateDisplay(a.status),
              startedAt: _formatDateTime(a.startedAt),
              endedAt: _formatDateTime(a.endedAt),
              statusInfo: a.statusInfo,
            ),
          )
          .toList();

      final status = attempts.isEmpty
          ? const ProjectStatus(
              deploymentState: 'Never deployed',
              lastDeployTime: null,
              environment: null,
            )
          : ProjectStatus(
              deploymentState: _deploymentStateDisplay(attempts.first.status),
              lastDeployTime: _formatDateTime(
                attempts.first.endedAt ?? attempts.first.startedAt,
              ),
              environment: null,
            );

      return (status: status, deployAttempts: deployAttempts);
    } on FailureException catch (e) {
      AppDebug.logError(
        'ProjectRepository',
        'fetchProjectDetails failed: ${e.reason}',
      );
      rethrow;
    } catch (e) {
      AppDebug.logError('ProjectRepository', 'fetchProjectDetails error: $e');
      rethrow;
    } finally {
      provider.shutdown();
    }
  }

  String? _formatDateTime(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _deploymentStateDisplay(DeployProgressStatus status) {
    return switch (status) {
      DeployProgressStatus.success => 'Live',
      DeployProgressStatus.running => 'Deploying',
      DeployProgressStatus.awaiting => 'Deploying',
      DeployProgressStatus.failure => 'Failed',
      DeployProgressStatus.cancelled => 'Cancelled',
      DeployProgressStatus.unknown => 'Unknown',
    };
  }

  /// Fetches build log records for a deploy attempt.
  ///
  /// [projectId] is the cloud capsule/project id. Collects the stream into
  /// a list and shuts down the provider when done.
  Future<List<LogRecord>> fetchBuildLog(
    String projectId,
    String attemptId,
  ) async {
    final provider = CloudCliServiceProvider();
    provider.initialize(globalConfiguration: _globalConfig, logger: _logger);

    try {
      final client = provider.cloudApiClient;
      final stream = client.logs.fetchBuildLog(
        cloudCapsuleId: projectId,
        attemptId: attemptId,
      );
      final records = <LogRecord>[];
      await for (final record in stream) {
        records.add(record);
      }
      return records;
    } on FailureException catch (e) {
      AppDebug.logError(
        'ProjectRepository',
        'fetchBuildLog failed: ${e.reason}',
      );
      rethrow;
    } catch (e) {
      AppDebug.logError('ProjectRepository', 'fetchBuildLog error: $e');
      rethrow;
    } finally {
      provider.shutdown();
    }
  }

  /// Streams container log records for a project (real-time tail).
  ///
  /// [projectId] is the cloud capsule id. Stream never completes; cancel
  /// the subscription and the controller's onCancel will shutdown the provider.
  Stream<LogRecord> streamContainerLogs(String projectId, {int limit = 500}) {
    late final CloudCliServiceProvider provider;
    late final StreamSubscription<LogRecord> subscription;

    final controller = StreamController<LogRecord>.broadcast();
    controller.onListen = () {
      provider = CloudCliServiceProvider();
      provider.initialize(globalConfiguration: _globalConfig, logger: _logger);
      final source = provider.cloudApiClient.logs.tailRecords(
        cloudCapsuleId: projectId,
        limit: limit,
      );
      subscription = source.listen(
        controller.add,
        onError: controller.addError,
        onDone: () {
          provider.shutdown();
        },
      );
    };
    controller.onCancel = () {
      subscription.cancel();
      provider.shutdown();
    };
    return controller.stream;
  }

  /// Resolves a [Project] from a server directory path.
  ///
  /// Returns the project if the directory contains a valid scloud.yaml linked
  /// to Cloud; returns null if invalid.
  Project? resolveProjectFromDirectory(String directoryPath) {
    final config = _tryReadConfigFromDirectory(directoryPath);
    if (config == null || config.projectId.isEmpty) {
      return null;
    }
    return Project(
      id: config.projectId,
      displayName: config.projectId,
      isLinked: true,
    );
  }

  ScloudConfig? _tryReadConfigFromDirectory(String directoryPath) {
    try {
      final configPath = '$directoryPath/scloud.yaml';
      return ScloudConfigIO.readFromFile(configPath);
    } catch (_) {
      return null;
    }
  }
}
