import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool obscureText;
  final bool autofocus;
  final String? errorText;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.errorText,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(
                  alpha: 0.1 * _focusAnimation.value,
                ),
                blurRadius: 10.0,
                offset: const Offset(0, 4.0),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            style: AppTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: _isFocused
                            ? AppTheme.primaryGreen
                            : AppTheme.textSecondary,
                      ),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(color: AppTheme.dividerColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(color: AppTheme.dividerColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(color: AppTheme.errorRed, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
              ),
              errorText: widget.errorText,
              errorStyle: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingM,
              ),
            ),
          ),
        );
      },
    );
  }
}
