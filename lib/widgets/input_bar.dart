import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../design_system.dart';
import '../services/storage_service.dart';

typedef SendMessageCallback = Future<void> Function(String text, {String? imageUrl});

class InputBar extends StatefulWidget {
  final SendMessageCallback onSendMessage;
  final String chatId;

  const InputBar({super.key, required this.onSendMessage, required this.chatId});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textEditingController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.selectionClick();
      widget.onSendMessage(text);
      _textEditingController.clear();
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final url = await StorageService.uploadChatImageBytes(bytes, widget.chatId);
      await widget.onSendMessage('', imageUrl: url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image send failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.small),
          child: IconButton(
            onPressed: _pickAndSendImage,
            icon: const Icon(Icons.image, color: AppColors.primary),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: AppSpacing.small),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _textEditingController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
              maxLines: null,
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                spreadRadius: 2,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.white, size: 20),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
