part of 'auth_bloc.dart';

/// Base class for authentication events.
abstract class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered when the Firebase Auth user changes.
///
/// [user] is null when signed out, non-null when signed in.
class AuthUserChanged extends AuthEvent {
  /// Creates an [AuthUserChanged] event with the current user.
  const AuthUserChanged(this.user);

  /// The current Firebase Auth user, or null if signed out.
  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}
