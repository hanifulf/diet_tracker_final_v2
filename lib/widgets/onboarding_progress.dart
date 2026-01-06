import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator text
        Text(
          'Langkah $currentStep dari $totalSteps',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingS),
        
        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: currentStep / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.accentTeaGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

