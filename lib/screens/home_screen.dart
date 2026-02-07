import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system.dart';
import '../models/expert.dart';
import '../widgets/expert_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/chat_history_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Expert> experts = const [
    Expert(name: 'Tutor', icon: Icons.school),
    Expert(name: 'Psychologist', icon: Icons.psychology),
    Expert(name: 'Musician', icon: Icons.music_note),
    Expert(name: 'Fitness Instructor', icon: Icons.fitness_center),
    Expert(name: 'Content Creator', icon: Icons.create),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expert Assistant', style: AppTextStyles.h1),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose an expert to start a conversation',
                style: AppTextStyles.h3.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: experts.length,
                  itemBuilder: (context, index) {
                    final expert = experts[index];
                    return ExpertCard(
                      expert: expert,
                      onTap: () {
                        context.push('/chat', extra: expert);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
