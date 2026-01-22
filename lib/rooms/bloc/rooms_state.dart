part of 'rooms_bloc.dart';

/// Status of the rooms list loading process.
enum RoomsStatus {
  /// Initial state, no action taken.
  idle,

  /// Rooms are being loaded.
  loading,

  /// Rooms loaded successfully.
  loaded,

  /// Failed to load rooms.
  failure,
}

/// Represents a chat room in the room list.
class RoomListItem extends Equatable {
  /// Creates a [RoomListItem] with room details.
  const RoomListItem({
    required this.id,
    required this.type,
    required this.memberIds,
    this.name,
    this.lastMessageText,
  });

  /// Unique room identifier.
  final String id;

  /// Room type: 'direct' for 1-on-1, 'group' for group chats.
  final String type;

  /// List of user IDs who are members of this room.
  final List<String> memberIds;

  /// Display name of the room.
  final String? name;

  /// Preview text of the last message.
  final String? lastMessageText;

  @override
  List<Object?> get props => [id, type, memberIds, name, lastMessageText];
}

/// State of the rooms list.
class RoomsState extends Equatable {
  /// Creates a [RoomsState] with optional parameters.
  const RoomsState({
    this.status = RoomsStatus.loading,
    this.rooms = const [],
    this.errorMessage,
  });

  /// Current loading status.
  final RoomsStatus status;

  /// List of rooms the user is a member of.
  final List<RoomListItem> rooms;

  /// Error message if loading failed.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  RoomsState copyWith({
    RoomsStatus? status,
    List<RoomListItem>? rooms,
    String? errorMessage,
  }) {
    return RoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rooms, errorMessage];
}
