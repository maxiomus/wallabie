part of 'chat_bloc.dart';

enum ChatStatus { loading, loaded, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.loading,
    //this.messages = const [],
    this.errorMessage,
  });

  final ChatStatus status;
  //final List<types.Message> messages;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    //List<types.Message>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      //messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

