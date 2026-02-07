import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';
import '../models/expert.dart';

class ExpertCard extends StatelessWidget {
  final Expert expert;
  final VoidCallback onTap;

  const ExpertCard({super.key, required this.expert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.large),
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
              child: Icon(expert.icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              expert.name,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
