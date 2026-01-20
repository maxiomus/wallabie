part of 'rooms_bloc.dart';

enum RoomsStatus { idle, loading, loaded, failure }

class RoomListItem extends Equatable {
  const RoomListItem({
    required this.id,
    required this.type,
    required this.memberIds,
    this.name,
    this.lastMessageText,
  });

  final String id;
  final String type; // direct | group
  final List<String> memberIds;
  final String? name;
  final String? lastMessageText;

  @override
  List<Object?> get props => [id, type, memberIds, name, lastMessageText];
}

class RoomsState extends Equatable {
  const RoomsState({
    this.status = RoomsStatus.loading,
    this.rooms = const [],
    this.errorMessage,
  });

  final RoomsStatus status;
  final List<RoomListItem> rooms;
  final String? errorMessage;

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
