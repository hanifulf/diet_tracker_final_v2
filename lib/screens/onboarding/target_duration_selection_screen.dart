import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/onboarding_progress.dart';
import '../../widgets/selection_card.dart';
import '../../models/user_model.dart';
import '../main_navigation_screen.dart';
import '../../services/user_local_storage.dart';

class TargetDurationSelectionScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int age;
  final double height;
  final double currentWeight;
  final double targetWeight;

  const TargetDurationSelectionScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  State<TargetDurationSelectionScreen> createState() =>
      _TargetDurationSelectionScreenState();
}

class _TargetDurationSelectionScreenState
    extends State<TargetDurationSelectionScreen> {
  int? _selectedDuration;

  void _selectDuration(int duration) {
    setState(() {
      _selectedDuration = duration;
    });
  }

  void _completeOnboarding() async {
    if (_selectedDuration == null) return;

    // Create user model
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.name,
      gender: widget.gender,
      age: widget.age,
      height: widget.height,
      currentWeight: widget.currentWeight,
      targetWeight: widget.targetWeight,
      targetDuration: _selectedDuration!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // TODO: Save user data to local storage
    await UserLocalStorage.saveUser(user);
    // Navigate to main app
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainNavigationScreen(user: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.mediumAnimation,
      ),
      (route) => false,
    );
  }

  String _getDurationText(int days) {
    if (days < 30) {
      return '$days hari';
    } else if (days < 365) {
      final months = (days / 30).round();
      return '$months bulan';
    } else {
      final years = (days / 365).round();
      return '$years tahun';
    }
  }

  String _getRecommendationText(int days) {
    final weightDifference = (widget.targetWeight - widget.currentWeight).abs();
    final weeklyChange = (weightDifference / (days / 7));

    if (weeklyChange <= 0.5) {
      return 'Sangat aman dan berkelanjutan';
    } else if (weeklyChange <= 1.0) {
      return 'Aman dan realistis dilakukan';
    } else {
      return 'Butuh komitmen tinggi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationOptions = [30, 60, 90, 180, 365];

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
              const OnboardingProgress(currentStep: 7, totalSteps: 7),

              const SizedBox(height: AppTheme.spacingXL),

              // Title and Subtitle
              Text(
                'Kapan kamu ingin mencapai target?',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              Text(
                'Pilih durasi yang realistis untuk mencapai target berat badan kamu.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Duration Selection Cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacingM,
                    mainAxisSpacing: AppTheme.spacingM,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: durationOptions.length,
                  itemBuilder: (context, index) {
                    final duration = durationOptions[index];
                    return SelectionCard(
                      title: _getDurationText(duration),
                      subtitle: _getRecommendationText(duration),
                      icon: Icons.schedule_rounded,
                      isSelected: _selectedDuration == duration,
                      onTap: () => _selectDuration(duration),
                    );
                  },
                ),
              ),

              // Complete Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _selectedDuration != null
                      ? _completeOnboarding
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedDuration != null
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    elevation: _selectedDuration != null ? 4 : 0,
                    shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Mulai Perjalanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Icon(Icons.rocket_launch_rounded, size: 20),
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
