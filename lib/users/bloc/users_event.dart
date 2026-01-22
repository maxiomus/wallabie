part of 'users_bloc.dart';

/// Base class for user list events.
sealed class UsersEvent extends Equatable {
  /// Creates a [UsersEvent].
  const UsersEvent();

  @override
  List<Object> get props => [];
}

/// Event to start streaming the list of all users.
final class UsersStartEvent extends UsersEvent {
  /// Creates a [UsersStartEvent].
  const UsersStartEvent();

  @override
  List<Object> get props => [];
}
