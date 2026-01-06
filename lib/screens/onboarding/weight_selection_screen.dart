import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/onboarding_progress.dart';
import '../../widgets/number_picker_widget.dart';
import 'target_weight_selection_screen.dart';

class WeightSelectionScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int age;
  final double height;

  const WeightSelectionScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
  });

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  int _selectedWeight = 70;

  void _onWeightChanged(int weight) {
    setState(() {
      _selectedWeight = weight;
    });
  }

  void _navigateToTargetWeightSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TargetWeightSelectionScreen(
              name: widget.name,
              gender: widget.gender,
              age: widget.age,
              height: widget.height,
              currentWeight: _selectedWeight.toDouble(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.mediumAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              const OnboardingProgress(currentStep: 5, totalSteps: 7),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Title and Subtitle
              Text(
                'Berapa berat badan kamu saat ini?',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Berat badan saat ini akan menjadi titik awal untuk mencapai target kamu.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Weight Picker
              Expanded(
                child: Center(
                  child: NumberPickerWidget(
                    minValue: 30,
                    maxValue: 200,
                    initialValue: _selectedWeight,
                    suffix: 'kg',
                    onChanged: _onWeightChanged,
                  ),
                ),
              ),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToTargetWeightSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}

