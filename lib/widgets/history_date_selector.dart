import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HistoryDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const HistoryDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Previous day button
          IconButton(
            onPressed: () => _changeDate(-1),
            icon: Icon(
              Icons.chevron_left_rounded,
              color: AppTheme.primaryGreen,
            ),
          ),
          
          // Date display and picker
          Expanded(
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                  horizontal: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      _formatDate(selectedDate),
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Next day button
          IconButton(
            onPressed: _canGoToNextDay() ? () => _changeDate(1) : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: _canGoToNextDay() 
                  ? AppTheme.primaryGreen 
                  : AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    final newDate = selectedDate.add(Duration(days: days));
    onDateChanged(newDate);
  }

  bool _canGoToNextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final startOfSelectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    return startOfSelectedDate.isBefore(startOfTomorrow);
  }

  void _showDatePicker() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.cardBackground,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateChanged(pickedDate);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hari Ini';
    } else if (selectedDay == yesterday) {
      return 'Kemarin';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      
      return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
    }
  }
}

// Global navigator key for date picker
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

