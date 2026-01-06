import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/onboarding_progress.dart';
import '../../widgets/number_picker_widget.dart';
import 'weight_selection_screen.dart';

class HeightSelectionScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int age;

  const HeightSelectionScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
  });

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int _selectedHeight = 170;

  void _onHeightChanged(int height) {
    setState(() {
      _selectedHeight = height;
    });
  }

  void _navigateToWeightSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WeightSelectionScreen(
              name: widget.name,
              gender: widget.gender,
              age: widget.age,
              height: _selectedHeight.toDouble(),
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
              const OnboardingProgress(currentStep: 4, totalSteps: 7),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Title and Subtitle
              Text(
                'Berapa tinggi badan kamu?',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Tinggi badan diperlukan untuk menghitung BMR dan kebutuhan kalori yang akurat.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Height Picker
              Expanded(
                child: Center(
                  child: NumberPickerWidget(
                    minValue: 120,
                    maxValue: 220,
                    initialValue: _selectedHeight,
                    suffix: 'cm',
                    onChanged: _onHeightChanged,
                  ),
                ),
              ),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToWeightSelection,
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

