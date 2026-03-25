import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const _groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _model = 'llama-3.3-70b-versatile';

  ChatBloc() : super(const ChatState()) {
    on<ChatInitialized>(_onInitialized);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatCleared>(_onCleared);
  }

  void _onInitialized(ChatInitialized event, Emitter<ChatState> emit) {
    final profile = UserProfileService.getProfile();
    final name = profile?.name.split(' ').first ?? 'there';
    final welcome = ChatMessage(
      text: 'Hey $name! 💪 I\'m your AI fitness coach powered by Groq. '
          'Ask me anything about workouts, nutrition, recovery, or your fitness goals. I\'m here to help!',
      isUser: false,
      time: DateTime.now(),
    );
    emit(state.copyWith(status: ChatStatus.ready, messages: [welcome]));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (event.text.trim().isEmpty) return;

    final userMsg = ChatMessage(
        text: event.text.trim(), isUser: true, time: DateTime.now());
    final updatedMessages = [...state.messages, userMsg];

    emit(state.copyWith(status: ChatStatus.typing, messages: updatedMessages));

    try {
      final profile = UserProfileService.getProfile();
      final systemPrompt = _buildSystemPrompt(profile);

      final conversationMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...updatedMessages.map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        }),
      ];

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': conversationMessages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      String replyText;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        replyText = data['choices'][0]['message']['content'] ??
            'Sorry, I couldn\'t process that. Try again!';
      } else {
        final error = jsonDecode(response.body);
        replyText =
        '⚠️ ${error['error']['message'] ?? 'Something went wrong. Try again!'}';
      }

      final replyMsg =
      ChatMessage(text: replyText, isUser: false, time: DateTime.now());
      emit(state.copyWith(
          status: ChatStatus.ready,
          messages: [...updatedMessages, replyMsg]));
    } catch (_) {
      final errMsg = ChatMessage(
        text: '⚠️ Network error. Please check your connection and try again.',
        isUser: false,
        time: DateTime.now(),
      );
      emit(state.copyWith(
          status: ChatStatus.ready,
          messages: [...updatedMessages, errMsg]));
    }
  }

  void _onCleared(ChatCleared event, Emitter<ChatState> emit) {
    add(ChatInitialized());
  }

  String _buildSystemPrompt(UserProfile? profile) {
    String profileInfo = '';
    if (profile != null) {
      profileInfo = '''
User Profile:
- Name: ${profile.name}
- Age: ${profile.age}
- Weight: ${profile.weight}kg
- Height: ${profile.height}cm
- BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})
- Goals: ${profile.fitnessGoal}
- Level: ${profile.fitnessLevel}
''';
    }
    return '''
You are an expert AI personal fitness coach. You give personalized, practical, science-based fitness advice.

$profileInfo

Guidelines:
- Keep responses concise (2-4 sentences max unless a detailed plan is requested)
- Be encouraging and motivating
- Always consider the user\'s fitness level and goals
- If asked about injuries or medical conditions, recommend consulting a doctor
- Use simple language, avoid jargon
- Add relevant emojis to make responses friendly
- Never recommend dangerous exercises or extreme diets
''';
  }
}