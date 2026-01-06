import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class MacroDetailsCard extends StatelessWidget {
  final double currentCarbs;
  final double currentProteins;
  final double currentFats;
  final double targetCalories;

  const MacroDetailsCard({
    super.key,
    required this.currentCarbs,
    required this.currentProteins,
    required this.currentFats,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate target macros based on standard percentages
    final targetCarbsGrams = (targetCalories * 0.5) / 4; // 50% carbs, 4 cal/g
    final targetProteinsGrams =
        (targetCalories * 0.25) / 4; // 25% protein, 4 cal/g
    final targetFatsGrams = (targetCalories * 0.25) / 9; // 25% fats, 9 cal/g

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 1),
        Text(
          'Detail Kalori',
          style: AppTheme.headingSmall.copyWith(
            fontSize: 12, // lebih kecil
            color: const Color.fromARGB(255, 161, 161, 161),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Carbohydrates
        _buildMacroRow(
          'Karbohidrat',
          currentCarbs,
          targetCarbsGrams,
          'g',
          AppTheme.warningOrange,
          Icons.grain_rounded,
        ),

        const SizedBox(height: 14),

        // Proteins
        _buildMacroRow(
          'Protein',
          currentProteins,
          targetProteinsGrams,
          'g',
          AppTheme.primaryGreen,
          Icons.fitness_center_rounded,
        ),

        const SizedBox(height: 14),

        // Fats
        _buildMacroRow(
          'Lemak',
          currentFats,
          targetFatsGrams,
          'g',
          AppTheme.accentTeaGreen,
          Icons.water_drop_rounded,
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    String name,
    double current,
    double target,
    String unit,
    Color color,
    IconData icon,
  ) {
    final progress = current / target;

    return Column(
      children: [
        // Header row
        Row(
          children: [
            Container(
              width: 20, // lebih kecil
              height: 20, // lebih kecil
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 14, color: color), // ikon diperkecil
            ),

            const SizedBox(width: AppTheme.spacingS),

            Expanded(
              child: Text(
                name,
                style: AppTheme.bodyMedium.copyWith(
                  // font lebih kecil
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)} $unit',
              style: AppTheme.bodySmall.copyWith(
                // font lebih kecil
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingXS),

        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft, // biar start kiri
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft, // tetap kiri
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
