part of 'chat_bloc.dart';

/// Base class for chat events.
@immutable
sealed class ChatEvent extends Equatable {
  /// Creates a [ChatEvent].
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Event to start streaming messages for the chat room.
final class ChatStartEvent extends ChatEvent {
  /// Creates a [ChatStartEvent].
  const ChatStartEvent();

  @override
  List<Object> get props => [];
}
