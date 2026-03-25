import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  UserProfile? _profile;

  static const _groqApiKey = String.fromEnvironment('GROQ_API_KEY');  static const _model = 'llama-3.3-70b-versatile';

  final List<String> _quickPrompts = [
    'What should I eat before a workout?',
    'How do I fix knee pain during squats?',
    'Best exercises for beginners?',
    'How many rest days per week?',
    'How to build muscle faster?',
    'What is progressive overload?',
  ];

  @override
  void initState() {
    super.initState();
    _profile = UserProfileService.getProfile();
    _sendWelcome();
  }

  String _buildSystemPrompt() {
    final profile = _profile;
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
- Always consider the user's fitness level and goals
- If asked about injuries or medical conditions, recommend consulting a doctor
- Use simple language, avoid jargon
- Add relevant emojis to make responses friendly
- Never recommend dangerous exercises or extreme diets
''';
  }

  void _sendWelcome() {
    final name = _profile?.name.split(' ').first ?? 'there';
    _messages.add(ChatMessage(
      text:
      'Hey $name! 💪 I\'m your AI fitness coach powered by Groq. Ask me anything about workouts, nutrition, recovery, or your fitness goals. I\'m here to help!',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages
          .add(ChatMessage(text: text.trim(), isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final conversationMessages = [
        {'role': 'system', 'content': _buildSystemPrompt()},
        ..._messages.map((m) => {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] ??
            'Sorry, I couldn\'t process that. Try again!';

        if (mounted) {
          setState(() {
            _messages.add(
                ChatMessage(text: reply, isUser: false, time: DateTime.now()));
            _isTyping = false;
          });
          _scrollToBottom();
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMsg =
            error['error']['message'] ?? 'Something went wrong. Try again!';
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: '⚠️ $errorMsg',
              isUser: false,
              time: DateTime.now(),
            ));
            _isTyping = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text:
            '⚠️ Network error. Please check your connection and try again.',
            isUser: false,
            time: DateTime.now(),
          ));
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Coach',
                style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            Text('Powered by Groq',
                style: TextStyle(
                    color: AppTheme.grey.withOpacity(0.6), fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: AppTheme.grey.withOpacity(0.6), size: 20),
            onPressed: () {
              setState(() {
                _messages.clear();
                _sendWelcome();
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length) return _buildTypingIndicator();
              return _buildMessage(_messages[i]);
            },
          ),
        ),

        if (_messages.length <= 1) _buildQuickPrompts(),

        _buildInputBar(),
      ]),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 11),
                  ),
                  const SizedBox(width: 6),
                  Text('AI Coach',
                      style: TextStyle(
                          color: AppTheme.grey.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: AppTheme.border),
              ),
              child: Text(msg.text,
                  style: TextStyle(
                      color: isUser ? Colors.white : AppTheme.white,
                      fontSize: 14,
                      height: 1.5)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: AppTheme.grey.withOpacity(0.4), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _TypingDot(delay: 0),
          const SizedBox(width: 4),
          _TypingDot(delay: 200),
          const SizedBox(width: 4),
          _TypingDot(delay: 400),
        ]),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(_quickPrompts[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
              Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Text(_quickPrompts[i],
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: AppTheme.white, fontSize: 14),
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ask your AI coach anything...',
              hintStyle: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4), fontSize: 14),
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: _sendMessage,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _sendMessage(_controller.text),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child:
            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color:
          AppTheme.primary.withOpacity(0.3 + (_anim.value * 0.7)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}