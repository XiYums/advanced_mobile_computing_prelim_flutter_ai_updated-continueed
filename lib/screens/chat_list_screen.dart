import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../design_system.dart';
import '../models/expert.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/chat_history_drawer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _userName = 'User';
  String? _lastExpertName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'User';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastExpertName = prefs.getString('last_expert');
    });
  }

  Future<void> _navigateToChat() async {
    if (_lastExpertName != null) {
      // Navigate to the last used expert
      final expert = _getExpertFromName(_lastExpertName!);
      if (expert != null) {
        context.push('/chat', extra: expert);
      } else {
        // If expert not found, go to home to select
        context.go('/home');
      }
    } else {
      // No last expert, go to home to select
      context.go('/home');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.go('/profile'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        title: Text('Chats', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.regular),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
              title: Text('New Chat', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
              onTap: () {
                context.go('/home');
              },
            ),
            if (_lastExpertName != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: const Icon(Icons.chat, color: AppColors.primary),
                ),
                title: Text('Continue with $_lastExpertName', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                subtitle: Text('Resume your last conversation', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                onTap: _navigateToChat,
              ),
            const Spacer(),
            Card(
              margin: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                            Text('Tap to view profile', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.go('/profile');
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
