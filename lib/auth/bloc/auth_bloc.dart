import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:august_chat/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc that manages authentication state across the application.
///
/// Listens to Firebase Auth state changes and emits corresponding
/// [AuthState] updates (authenticated, unauthenticated, or unknown).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc] with the given [AuthRepository].
  AuthBloc(this._repo) : super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);

    _sub = _repo.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<User?> _sub;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(user));
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

