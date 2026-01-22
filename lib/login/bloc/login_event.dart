part of 'login_bloc.dart';

/// Base class for login events.
sealed class LoginEvent extends Equatable {
  /// Creates a [LoginEvent].
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the user submits the login form.
final class LoginSubmitEvent extends LoginEvent {
  /// Creates a [LoginSubmitEvent] with email and password.
  const LoginSubmitEvent(this.email, this.password);

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  @override
  List<Object> get props => [email, password];
}
