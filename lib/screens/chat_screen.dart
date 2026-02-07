import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system.dart';
import '../models/chat_message.dart';
import '../models/expert.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/chat_history_drawer.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  final Expert expert;

  const ChatScreen({super.key, required this.expert});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _saveLastExpert();
    // Add initial welcome message
    messages.add(
      ChatMessage(
        text:
            'Hello! I\'m your ${widget.expert.name} assistant. How can I help you today?',
        role: 'model',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _saveLastExpert() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_expert', widget.expert.name);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void addMessage(String text, String role, {String? imageUrl}) {
    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          role: role, // "user" or "model"
          timestamp: DateTime.now(),
          imageUrl: imageUrl,
        ),
      );
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🔥 MULTI-TURN HANDLER
  Future<void> handleSend(String text, {String? imageUrl}) async {
    // Add user message (text or image)
    addMessage(text, "user", imageUrl: imageUrl);

    setState(() => _isLoading = true);

    try {
      // 🔥 SEND ENTIRE HISTORY TO GEMINI
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages, // ← Entire conversation!
        widget.expert,
      );

      // Add AI response
      addMessage(aiResponse, "model"); // ← role: "model"

      // Save chat history
      await saveChatHistory(widget.expert.name, aiResponse);
    } catch (e) {
      final errorMessage = '❌ Error: $e';
      addMessage(errorMessage, "model");

      // Save error message to chat history
      await saveChatHistory(widget.expert.name, errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                widget.expert.icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.expert.name, style: AppTextStyles.h3),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                messages.clear();
              });
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Messages
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.expert.icon,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start chatting with ${widget.expert.name}',
                            style: AppTextStyles.h3.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask anything and get expert help!',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return ChatBubble(message: msg);
                      },
                    ),
            ),

            // Loading
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(4),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Thinking...',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

            // Input
            Container(
              padding: const EdgeInsets.all(AppSpacing.regular),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: InputBar(onSendMessage: handleSend, chatId: widget.expert.name),
            ),
          ],
        ),
      ),
    );
  }
}
