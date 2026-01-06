import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/user_local_storage.dart';
import 'onboarding/name_input_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: AppTheme.longAnimation,
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );

    // Logo scale animation
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Fade animation for text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimations();
    _checkUserAndNavigate();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _fadeController.forward();
  }

  Future<void> _checkUserAndNavigate() async {
    final user = await UserLocalStorage.getUser();

    // Tunggu animasi minimum
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    if (user != null) {
      // ✅ User sudah onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainNavigationScreen(user: user),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppTheme.mediumAnimation,
        ),
      );
    } else {
      // ❌ Belum onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const NameInputScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppTheme.mediumAnimation,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 280,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXL,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXL,
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // Subtitle Fade
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Hidup Chill Makan Still',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
