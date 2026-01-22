part of 'chat_bloc.dart';

/// Status of the chat loading process.
enum ChatStatus {
  /// Messages are being loaded.
  loading,

  /// Messages loaded successfully.
  loaded,

  /// Failed to load messages.
  failure,
}

/// State of a chat conversation.
class ChatState extends Equatable {
  /// Creates a [ChatState] with optional parameters.
  const ChatState({
    this.status = ChatStatus.loading,
    this.errorMessage,
  });

  /// Current loading status.
  final ChatStatus status;

  /// Error message if loading failed.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  ChatState copyWith({
    ChatStatus? status,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

