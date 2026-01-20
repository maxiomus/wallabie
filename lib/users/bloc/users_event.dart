part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

final class UsersStartEvent extends UsersEvent {
  const UsersStartEvent();

  @override
  List<Object> get props => [];
}
