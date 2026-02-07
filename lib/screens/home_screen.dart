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
    Expert(name: 'Add Persona', icon: Icons.person_add),
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
                    // Special tile for creating/ managing personas
                    if (expert.name == 'Add Persona') {
                      return GestureDetector(
                        onTap: () => context.push('/personas'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.large),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(AppSpacing.card),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_add, size: 36, color: AppColors.primary),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add Persona',
                                style: AppTextStyles.h3,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

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
