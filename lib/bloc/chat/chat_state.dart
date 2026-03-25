part of 'chat_bloc.dart';

enum ChatStatus { initial, ready, typing, error }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatState {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String error;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error = '',
  });

  bool get isTyping => status == ChatStatus.typing;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}