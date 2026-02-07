import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../design_system.dart';
import '../services/voice_service.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final VoiceService _voiceService = VoiceService();
  bool _isSpeaking = false;

  Future<void> _playMessage() async {
    if (_isSpeaking) {
      await _voiceService.stopSpeaking();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _voiceService.speak(widget.message.text);
      setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUserMessage;
    final bg = isUser ? AppColors.primary : AppColors.background;
    final txtColor = isUser ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: AppSpacing.regular,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.large),
            topRight: const Radius.circular(AppRadius.large),
            bottomLeft: isUser
                ? const Radius.circular(AppRadius.large)
                : const Radius.circular(AppRadius.small),
            bottomRight: isUser
                ? const Radius.circular(AppRadius.small)
                : const Radius.circular(AppRadius.large),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (widget.message.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.message.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: 160,
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                  width: 160,
                  height: 120,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (widget.message.text.isNotEmpty)
                        Text(
                          widget.message.text,
                          style: AppTextStyles.bodyLarge.copyWith(color: txtColor),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.message.timestamp.hour}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.caption.copyWith(
                          color: isUser ? Colors.white70 : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUser && widget.message.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _playMessage,
                    child: Icon(
                      _isSpeaking ? Icons.stop_circle : Icons.play_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
