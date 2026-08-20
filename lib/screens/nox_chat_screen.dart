// nox_chat_screen.dart
// Dedicated chat interface for Nox, the AI fitness coach. Persists
// history via StorageService and calls Gemini through GeminiService.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

class NoxChatScreen extends StatefulWidget {
  const NoxChatScreen({super.key});

  @override
  State<NoxChatScreen> createState() => _NoxChatScreenState();
}

class _NoxChatScreenState extends State<NoxChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await StorageService.getChatHistory();
    if (!mounted) return;
    setState(() {
      _messages = history.isEmpty
          ? [
              ChatMessage(
                text:
                    'I am Nox. Tell me your goal and I will help you build the '
                    'discipline to reach it. Muscle, fat loss, or both - where '
                    'do we start?',
                fromUser: false,
              )
            ]
          : history;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final userMessage = ChatMessage(text: text, fromUser: true);
    setState(() {
      _messages = [..._messages, userMessage];
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();
    await StorageService.saveChatHistory(_messages);

    try {
      // Keep history short (last 8 turns) so every request stays light.
      final recent = _messages
          .skip(_messages.length > 8 ? _messages.length - 8 : 0)
          .map((m) => '${m.fromUser ? 'User' : 'Nox'}: ${m.text}')
          .toList();

      final UserProfile profile = await StorageService.getUserProfile();
      final recentWorkouts = await StorageService.getRecentWorkoutTitles(limit: 3);

      final reply = await GeminiService.askNox(
        message: text,
        recentHistory: recent,
        goal: profile.goal,
        experience: profile.experience,
        recentWorkouts: recentWorkouts,
      );

      if (!mounted) return;
      setState(() {
        _messages = [..._messages, ChatMessage(text: reply, fromUser: false)];
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(
            text:
                'I could not reach the coaching service right now. '
                'Check that GEMINI_API_KEY is set in .env and try again.',
            fromUser: false,
          ),
        ];
        _sending = false;
      });
    }

    await StorageService.saveChatHistory(_messages);
    _scrollToBottom();
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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              radius: 16,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Nox - Fitness Coach', style: AppTextStyles.heading3()),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _messages.length) {
                    return _TypingBubble();
                  }
                  final m = _messages[index];
                  return _ChatBubble(message: m);
                },
              ),
            ),
            _InputBar(controller: _controller, onSend: _send, sending: _sending),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : AppColors.darkSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 14),
          ),
          border: isUser ? null : Border.all(color: AppColors.divider),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body(color: Colors.white),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const SizedBox(
          width: 18,
          height: 14,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.body(),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Ask Nox anything about training...',
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: sending ? null : onSend,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
