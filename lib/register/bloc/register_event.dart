part of 'register_bloc.dart';

/// Base class for registration events.
sealed class RegisterEvent extends Equatable {
  /// Creates a [RegisterEvent].
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the user submits the registration form.
final class RegisterSubmitEvent extends RegisterEvent {
  /// Creates a [RegisterSubmitEvent] with registration details.
  const RegisterSubmitEvent(this.email, this.password, this.displayName);

  /// The user's email address.
  final String email;

  /// The user's chosen password.
  final String password;

  /// The user's display name for chat.
  final String displayName;

  @override
  List<Object> get props => [email, password, displayName];
}
