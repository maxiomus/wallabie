part of 'auth_bloc.dart';

/// Represents the authentication state of the application.
class AuthState extends Equatable {
  const AuthState._({this.user});

  /// Initial state before auth status is determined.
  const AuthState.unknown() : this._();

  /// State when a user is signed in.
  const AuthState.authenticated(User user) : this._(user: user);

  /// State when no user is signed in.
  const AuthState.unauthenticated() : this._();

  /// The current Firebase Auth user, or null if not authenticated.
  final User? user;

  /// Returns true if a user is currently authenticated.
  bool get isAuthed => user != null;

  @override
  List<Object?> get props => [user?.uid];
}

