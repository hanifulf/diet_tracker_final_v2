import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DailySummaryCard extends StatelessWidget {
  final DateTime date;
  final double totalCalories;
  final double targetCalories;
  final double totalWater;
  final double targetWater;
  final int foodCount;

  const DailySummaryCard({
    super.key,
    required this.date,
    required this.totalCalories,
    required this.targetCalories,
    required this.totalWater,
    required this.targetWater,
    required this.foodCount,
  });

  @override
  Widget build(BuildContext context) {
    final calorieProgress = totalCalories / targetCalories;
    final waterProgress = totalWater / targetWater;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Harian',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '$foodCount Makanan',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Summary metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Kalori',
                  '${totalCalories.toStringAsFixed(0)}',
                  '${targetCalories.toStringAsFixed(0)}',
                  'kcal',
                  calorieProgress,
                  Icons.local_fire_department_rounded,
                  AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              Expanded(
                child: _buildMetricCard(
                  'Air Minum',
                  '${totalWater.toStringAsFixed(0)}',
                  '${targetWater.toStringAsFixed(0)}',
                  'ml',
                  waterProgress,
                  Icons.local_drink_rounded,
                  AppTheme.accentTeaGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Progress summary
          _buildProgressSummary(calorieProgress, waterProgress),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String current,
    String target,
    String unit,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and label
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppTheme.spacingXS),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Current value
          Text(
            current,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: AppTheme.spacingXS),

          // Target and progress
          Row(
            children: [
              Text(
                '/ $target $unit',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(double calorieProgress, double waterProgress) {
    final overallProgress = (calorieProgress + waterProgress) / 2;
    final status = _getProgressStatus(overallProgress);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: status['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: status['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(status['icon'], color: status['color'], size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              status['message'],
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 12,
                color: status['color'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getProgressStatus(double progress) {
    if (progress >= 0.9) {
      return {
        'color': AppTheme.successGreen,
        'icon': Icons.celebration_rounded,
        'message': 'Luar biasa! Target harian hampir tercapai! 🎉',
      };
    } else if (progress >= 0.7) {
      return {
        'color': AppTheme.primaryGreen,
        'icon': Icons.trending_up_rounded,
        'message': 'Bagus! Kamu sudah mencapai sebagian besar target hari ini.',
      };
    } else if (progress >= 0.4) {
      return {
        'color': AppTheme.warningOrange,
        'icon': Icons.schedule_rounded,
        'message': 'Masih ada waktu untuk mencapai target harian.',
      };
    } else {
      return {
        'color': AppTheme.errorRed,
        'icon': Icons.flag_rounded,
        'message': 'Ayo semangat! Masih banyak target yang perlu dicapai.',
      };
    }
  }
}
