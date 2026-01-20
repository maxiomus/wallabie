part of 'users_bloc.dart';

enum UsersStatus { loading, loaded, failure }

class UserListItem extends Equatable {
  const UserListItem({required this.id, required this.name, this.imageUrl});
  final String id;
  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];
}

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.loading,
    this.users = const [],
    this.errorMessage,
  });

  final UsersStatus status;
  final List<UserListItem> users;
  final String? errorMessage;

  UsersState copyWith({
    UsersStatus? status,
    List<UserListItem>? users,
    String? errorMessage,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}

