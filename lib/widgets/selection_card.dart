import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SelectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;

  const SelectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedContainer(
              duration: AppTheme.shortAnimation,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: widget.isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.dividerColor,
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 2.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.accentTeaGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 25,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Title
                  Text(
                    widget.title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Subtitle (if provided)
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      widget.subtitle!,
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
