part of 'users_bloc.dart';

/// Status of the users list loading process.
enum UsersStatus {
  /// Users are being loaded.
  loading,

  /// Users loaded successfully.
  loaded,

  /// Failed to load users.
  failure,
}

/// Represents a user in the user selection list.
class UserListItem extends Equatable {
  /// Creates a [UserListItem] with user details.
  const UserListItem({required this.id, required this.name, this.imageUrl});

  /// Unique user identifier (Firebase Auth UID).
  final String id;

  /// Display name of the user.
  final String name;

  /// Optional profile image URL.
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];
}

/// State of the users list.
class UsersState extends Equatable {
  /// Creates a [UsersState] with optional parameters.
  const UsersState({
    this.status = UsersStatus.loading,
    this.users = const [],
    this.errorMessage,
  });

  /// Current loading status.
  final UsersStatus status;

  /// List of all users.
  final List<UserListItem> users;

  /// Error message if loading failed.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
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

