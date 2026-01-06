import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (textColor ?? AppTheme.primaryGreen).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                color: textColor ?? AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            
            const SizedBox(width: AppTheme.spacingM),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing widget or arrow
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

