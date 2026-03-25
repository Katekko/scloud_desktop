import 'package:shared_preferences/shared_preferences.dart';

/// Persists local directory paths per project using SharedPreferences.
class ProjectDirectoryStorage {
  ProjectDirectoryStorage(this._prefs);

  static const _keyPrefix = 'project_dir_';

  final SharedPreferences _prefs;

  String? getDirectoryForProject(String projectId) {
    return _prefs.getString('$_keyPrefix$projectId');
  }

  Future<void> setDirectoryForProject(String projectId, String path) {
    return _prefs.setString('$_keyPrefix$projectId', path);
  }

  Future<void> clearDirectoryForProject(String projectId) {
    return _prefs.remove('$_keyPrefix$projectId');
  }
}
