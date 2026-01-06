import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeSelected;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ranges = ['Minggu', 'Bulan', '3 Bulan', '6 Bulan'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: ranges.map((range) {
          final isSelected = selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => onRangeSelected(range),
              child: AnimatedContainer(
                duration: AppTheme.shortAnimation,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                  horizontal: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  range,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.textSecondary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

