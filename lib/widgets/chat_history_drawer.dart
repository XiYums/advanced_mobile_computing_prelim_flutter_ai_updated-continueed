import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system.dart';
import '../models/expert.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({super.key});

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  List<Map<String, dynamic>> _chatHistory = [];
  List<Map<String, dynamic>> _filteredChatHistory = [];
  String _searchQuery = '';
  String _userName = 'User';
  String _userEmail = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'User';
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chat_history') ?? [];

    setState(() {
      _chatHistory = history
          .map((item) {
            final parts = item.split('|');
            if (parts.length >= 3) {
              return {
                'expert': parts[0],
                'lastMessage': parts[1],
                'timestamp': DateTime.parse(parts[2]),
              };
            }
            return null;
          })
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList();

      _filterChatHistory();
    });
  }

  void _filterChatHistory() {
    if (_searchQuery.isEmpty) {
      _filteredChatHistory = List.from(_chatHistory);
    } else {
      _filteredChatHistory = _chatHistory.where((chat) {
        final expertName = chat['expert'].toString().toLowerCase();
        final lastMessage = chat['lastMessage'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return expertName.contains(query) || lastMessage.contains(query);
      }).toList();
    }
  }

  void _openChat(String expertName) {
    final expert = _getExpertFromName(expertName);
    if (expert != null) {
      Navigator.of(context).pop(); // Close drawer
      context.push('/chat', extra: expert);
    }
  }

  void _startNewChat() {
    Navigator.of(context).pop(); // Close drawer
    context.go('/home');
  }

  void _editProfile() {
    Navigator.of(context).pop(); // Close drawer
    context.go('/profile');
  }

  Future<void> _switchAccount() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pop(); // Close drawer
      context.go('/sign-in');
    }
  }

  Expert? _getExpertFromName(String name) {
    const experts = [
      Expert(name: 'Tutor', icon: Icons.school),
      Expert(name: 'Psychologist', icon: Icons.psychology),
      Expert(name: 'Musician', icon: Icons.music_note),
      Expert(name: 'Fitness Instructor', icon: Icons.fitness_center),
      Expert(name: 'Content Creator', icon: Icons.create),
    ];
    return experts.where((expert) => expert.name == name).firstOrNull;
  }

  IconData _getExpertIcon(String expertName) {
    const iconMap = {
      'Tutor': Icons.school,
      'Psychologist': Icons.psychology,
      'Musician': Icons.music_note,
      'Fitness Instructor': Icons.fitness_center,
      'Content Creator': Icons.create,
    };
    return iconMap[expertName] ?? Icons.chat;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Chat History',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // New Chat Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _startNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('New Chat'),
            ),
          ),

          // Chat History List
          Expanded(
            child: _filteredChatHistory.isEmpty && _searchQuery.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chats found',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredChatHistory.isEmpty && _chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chat history yet',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with an expert',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredChatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = _filteredChatHistory[index];
                      final expertName = chat['expert'] as String;
                      final lastMessage = chat['lastMessage'] as String;
                      final timestamp = chat['timestamp'] as DateTime;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getExpertIcon(expertName),
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          expertName,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastMessage.length > 35
                                  ? '${lastMessage.substring(0, 35)}...'
                                  : lastMessage,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              _formatTimestamp(timestamp),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _openChat(expertName);
                        },
                      );
                    },
                  ),
          ),

          // User Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF6366F1),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                          Text(
                            _userEmail,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _editProfile();
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _switchAccount();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Switch Account'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[timestamp.weekday - 1]} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Method to save chat history from chat screen
Future<void> saveChatHistory(String expertName, String lastMessage) async {
  final prefs = await SharedPreferences.getInstance();
  final timestamp = DateTime.now().toIso8601String();
  final historyItem = '$expertName|$lastMessage|$timestamp';

  // Remove existing entry for this expert
  final currentHistory = prefs.getStringList('chat_history') ?? [];
  currentHistory.removeWhere((item) => item.startsWith('$expertName|'));

  // Add new entry at the beginning
  currentHistory.insert(0, historyItem);

  // Keep only last 10 chats
  if (currentHistory.length > 10) {
    currentHistory.removeRange(10, currentHistory.length);
  }

  await prefs.setStringList('chat_history', currentHistory);
}
