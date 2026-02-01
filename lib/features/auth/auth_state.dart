/// Auth flow states per data-model and contracts/login-flow.
sealed class AuthState {
  const AuthState();
}

/// No valid session; user can initiate login.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth flow started; waiting for user to complete sign-in in browser.
final class LoginInProgress extends AuthState {
  const LoginInProgress();
}

/// Valid session; identity available for display.
final class Authenticated extends AuthState {
  const Authenticated(this.identity);

  /// Display identifier (e.g. email) from Serverpod Cloud.
  final String identity;
}

/// Login failed, cancelled, or session invalid; show message and allow retry.
final class AuthError extends AuthState {
  const AuthError(this.message);

  /// User-facing message key or text (e.g. signInNotCompleted, sessionExpired).
  final String message;
}
