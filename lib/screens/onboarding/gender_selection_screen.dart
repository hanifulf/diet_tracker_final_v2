import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/onboarding_progress.dart';
import '../../widgets/selection_card.dart';
import 'age_selection_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  final String name;

  const GenderSelectionScreen({
    super.key,
    required this.name,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _navigateToAgeSelection() {
    if (_selectedGender == null) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AgeSelectionScreen(
              name: widget.name,
              gender: _selectedGender!,
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
              const OnboardingProgress(currentStep: 2, totalSteps: 7),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Title and Subtitle
              Text(
                'Halo ${widget.name}!',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Pilih jenis kelamin kamu untuk perhitungan kalori yang lebih akurat.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Gender Selection Cards
              Row(
                children: [
                  Expanded(
                    child: SelectionCard(
                      title: 'Laki-laki',
                      icon: Icons.male_rounded,
                      isSelected: _selectedGender == 'Laki-laki',
                      onTap: () => _selectGender('Laki-laki'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: SelectionCard(
                      title: 'Perempuan',
                      icon: Icons.female_rounded,
                      isSelected: _selectedGender == 'Perempuan',
                      onTap: () => _selectGender('Perempuan'),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGender != null ? _navigateToAgeSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender != null 
                        ? AppTheme.primaryGreen 
                        : AppTheme.textSecondary.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    elevation: _selectedGender != null ? 4 : 0,
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

