import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/onboarding_progress.dart';
import 'gender_selection_screen.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  void _navigateToGenderSelection() {
    if (_nameController.text.trim().isEmpty) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GenderSelectionScreen(name: _nameController.text.trim()),
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
              const OnboardingProgress(currentStep: 1, totalSteps: 7),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Title and Subtitle
              Text(
                'Siapa nama kamu?',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Kami akan menggunakan nama ini untuk menyapa kamu di aplikasi.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Name Input Field
              CustomTextField(
                controller: _nameController,
                focusNode: _nameFocus,
                hintText: 'Masukkan nama kamu',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _navigateToGenderSelection(),
                autofocus: true,
              ),
              
              const Spacer(),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _navigateToGenderSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled 
                        ? AppTheme.primaryGreen 
                        : AppTheme.textSecondary.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    elevation: _isButtonEnabled ? 4 : 0,
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

