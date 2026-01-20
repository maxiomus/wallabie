part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._({this.user});

  const AuthState.unknown() : this._();
  const AuthState.authenticated(User user) : this._(user: user);
  const AuthState.unauthenticated() : this._();

  final User? user;

  bool get isAuthed => user != null;

  @override
  List<Object?> get props => [user?.uid];
}

