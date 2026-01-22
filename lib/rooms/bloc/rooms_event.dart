part of 'rooms_bloc.dart';

/// Base class for room list events.
sealed class RoomsEvent extends Equatable {
  /// Creates a [RoomsEvent].
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

/// Event to start streaming the user's rooms.
///
/// Triggers subscription to both rooms and users streams.
final class RoomsStartEvent extends RoomsEvent {
  /// Creates a [RoomsStartEvent].
  const RoomsStartEvent();

  @override
  List<Object> get props => [];
}
