import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/features/deploy/project_directory_storage.dart';
import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'deploy_state.dart';

/// Cubit for managing local directory linking and project deployment.
class DeployCubit extends Cubit<DeployState> {
  DeployCubit(this._repository, this._directoryStorage)
    : super(const DeployDirectoryNotConfigured());

  final ProjectRepository _repository;
  final ProjectDirectoryStorage _directoryStorage;

  /// Loads the stored directory for [projectId].
  void loadDirectory(String projectId) {
    final path = _directoryStorage.getDirectoryForProject(projectId);
    if (path != null) {
      emit(DeployDirectoryConfigured(path));
    } else {
      emit(const DeployDirectoryNotConfigured());
    }
  }

  /// Opens a directory picker and validates the selection.
  /// Returns an error message if invalid, or null on success.
  Future<String?> pickDirectory(String projectId) async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return null; // user cancelled

    final configFile = File('$path/scloud.yaml');
    if (!configFile.existsSync()) {
      return 'invalidDirectory';
    }

    await _directoryStorage.setDirectoryForProject(projectId, path);
    emit(DeployDirectoryConfigured(path));
    return null;
  }

  /// Clears the stored directory for [projectId].
  Future<void> clearDirectory(String projectId) async {
    await _directoryStorage.clearDirectoryForProject(projectId);
    emit(const DeployDirectoryNotConfigured());
  }

  /// Deploys the project from the configured directory.
  Future<bool> deploy(String projectId) async {
    final currentState = state;
    final dirPath = switch (currentState) {
      DeployDirectoryConfigured(:final directoryPath) => directoryPath,
      DeployError(:final directoryPath) => directoryPath,
      _ => null,
    };
    if (dirPath == null) return false;

    emit(DeployInProgress(dirPath));
    try {
      await _repository.deployProject(
        projectId: projectId,
        projectDir: dirPath,
      );
      emit(DeployDirectoryConfigured(dirPath));
      return true;
    } catch (e) {
      AppDebug.logError('DeployCubit', 'deploy error: $e');
      emit(DeployError(directoryPath: dirPath, message: e.toString()));
      return false;
    }
  }
}
