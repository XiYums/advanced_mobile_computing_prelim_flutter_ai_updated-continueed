import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system.dart';
import '../models/expert.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) async {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Handle chat navigation
        final prefs = await SharedPreferences.getInstance();
        final lastExpertName = prefs.getString('last_expert');
        if (lastExpertName != null) {
          final expert = _getExpertFromName(lastExpertName);
          if (expert != null) {
            context.push('/chat', extra: expert);
            return;
          }
        }
        context.go('/chat-list');
        break;
      case 2:
        context.go('/profile');
        break;
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
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedLabelStyle: AppTextStyles.button.copyWith(
            color: AppColors.primary,
            fontSize: 12,
          ),
          unselectedLabelStyle: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: AppColors.muted,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 28),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
