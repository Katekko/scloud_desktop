/// Represents a Serverpod Cloud project in the project list.
///
/// Maps from [ProjectInfo] / Cloud API. Used for list display with
/// linked vs available indicator.
class Project {
  const Project({
    required this.id,
    required this.displayName,
    required this.isLinked,
  });

  /// Unique project id for API and current-project reference.
  final String id;

  /// Display name for the list (typically same as id).
  final String displayName;

  /// True if associated with a local server directory; false if in account
  /// but not necessarily linked.
  final bool isLinked;
}
