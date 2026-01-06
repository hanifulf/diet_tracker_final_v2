import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class WeightProgressCard extends StatefulWidget {
  final double currentWeight;
  final double targetWeight;
  final Function(double) onWeightUpdated;

  const WeightProgressCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.onWeightUpdated,
  });

  @override
  State<WeightProgressCard> createState() => _WeightProgressCardState();
}

class _WeightProgressCardState extends State<WeightProgressCard> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.currentWeight.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _showWeightInputDialog() {
    _weightController.text = widget.currentWeight.toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Update Berat Badan',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan berat badan terbaru kamu',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: _updateWeight,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _updateWeight() {
    final weightText = _weightController.text.trim();
    final weight = double.tryParse(weightText);

    if (weight != null && weight > 0 && weight < 300) {
      widget.onWeightUpdated(weight);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukkan berat badan yang valid'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightDifference = widget.currentWeight - widget.targetWeight;
    final isGoalReached = weightDifference.abs() <= 0.5;
    final progress = _calculateProgress();

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
                'Progress Berat Badan',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              IconButton(
                onPressed: _showWeightInputDialog,
                icon: Icon(Icons.edit_rounded, color: AppTheme.primaryGreen),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Current vs Target Weight
          Row(
            children: [
              Expanded(
                child: _buildWeightDisplay(
                  'Saat Ini',
                  widget.currentWeight,
                  AppTheme.primaryGreen,
                ),
              ),

              Container(width: 2, height: 40, color: AppTheme.dividerColor),

              Expanded(
                child: _buildWeightDisplay(
                  'Target',
                  widget.targetWeight,
                  AppTheme.accentTeaGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingS),

              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.accentTeaGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Status Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    _getStatusMessage(weightDifference, isGoalReached),
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightDisplay(String label, double weight, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _calculateProgress() {
    // This is a simplified progress calculation
    // In a real app, you'd track the initial weight and calculate based on that
    final totalWeightToLose = (widget.currentWeight - widget.targetWeight)
        .abs();
    if (totalWeightToLose <= 0.5) return 1.0;

    // Assume initial weight was 10kg more than current for demo
    const assumedInitialWeight = 80.0;
    final totalGoal = (assumedInitialWeight - widget.targetWeight).abs();
    final achieved = (assumedInitialWeight - widget.currentWeight).abs();

    return (achieved / totalGoal).clamp(0.0, 1.0);
  }

  Color _getStatusColor() {
    final weightDifference = widget.currentWeight - widget.targetWeight;
    final isGoalReached = weightDifference.abs() <= 0.5;

    if (isGoalReached) {
      return AppTheme.successGreen;
    } else if (weightDifference > 0) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.primaryGreen;
    }
  }

  IconData _getStatusIcon() {
    final weightDifference = widget.currentWeight - widget.targetWeight;
    final isGoalReached = weightDifference.abs() <= 0.5;

    if (isGoalReached) {
      return Icons.celebration_rounded;
    } else if (weightDifference > 0) {
      return Icons.trending_down_rounded;
    } else {
      return Icons.trending_up_rounded;
    }
  }

  String _getStatusMessage(double weightDifference, bool isGoalReached) {
    if (isGoalReached) {
      return 'Selamat! Kamu sudah mencapai target berat badan! 🎉';
    } else if (weightDifference > 0) {
      return 'Masih perlu turun ${weightDifference.toStringAsFixed(1)} kg lagi untuk mencapai target';
    } else {
      return 'Masih perlu naik ${weightDifference.abs().toStringAsFixed(1)} kg lagi untuk mencapai target';
    }
  }
}
