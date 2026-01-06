import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingS,
            bottom: AppTheme.spacingM,
          ),
          child: Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Section content
        Container(
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: _buildChildrenWithDividers(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      
      // Add divider between items (except for the last item)
      if (i < children.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
}

