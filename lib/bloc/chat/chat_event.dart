part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatInitialized extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String text;
  ChatMessageSent(this.text);
}

class ChatCleared extends ChatEvent {}