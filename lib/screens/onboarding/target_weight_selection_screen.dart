import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/onboarding_progress.dart';
import '../../widgets/number_picker_widget.dart';
import 'target_duration_selection_screen.dart';

class TargetWeightSelectionScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int age;
  final double height;
  final double currentWeight;

  const TargetWeightSelectionScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.currentWeight,
  });

  @override
  State<TargetWeightSelectionScreen> createState() => _TargetWeightSelectionScreenState();
}

class _TargetWeightSelectionScreenState extends State<TargetWeightSelectionScreen> {
  late int _selectedTargetWeight;

  @override
  void initState() {
    super.initState();
    // Set initial target weight slightly different from current weight
    _selectedTargetWeight = widget.currentWeight > 70 
        ? (widget.currentWeight - 5).round() 
        : (widget.currentWeight + 5).round();
  }

  void _onTargetWeightChanged(int targetWeight) {
    setState(() {
      _selectedTargetWeight = targetWeight;
    });
  }

  void _navigateToTargetDurationSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TargetDurationSelectionScreen(
              name: widget.name,
              gender: widget.gender,
              age: widget.age,
              height: widget.height,
              currentWeight: widget.currentWeight,
              targetWeight: _selectedTargetWeight.toDouble(),
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

  String _getGoalDescription() {
    final difference = _selectedTargetWeight - widget.currentWeight;
    if (difference > 0) {
      return 'Kamu ingin menambah berat badan sebanyak ${difference.abs().toStringAsFixed(0)} kg';
    } else if (difference < 0) {
      return 'Kamu ingin menurunkan berat badan sebanyak ${difference.abs().toStringAsFixed(0)} kg';
    } else {
      return 'Kamu ingin mempertahankan berat badan saat ini';
    }
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
              const OnboardingProgress(currentStep: 6, totalSteps: 7),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Title and Subtitle
              Text(
                'Berapa target berat badan kamu?',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Target berat badan akan membantu kami menghitung kebutuhan kalori harian yang tepat.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Goal Description Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeaGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: AppTheme.accentTeaGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getGoalDescription(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Target Weight Picker
              Expanded(
                child: Center(
                  child: NumberPickerWidget(
                    minValue: 30,
                    maxValue: 200,
                    initialValue: _selectedTargetWeight,
                    suffix: 'kg',
                    onChanged: _onTargetWeightChanged,
                  ),
                ),
              ),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToTargetDurationSelection,
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

