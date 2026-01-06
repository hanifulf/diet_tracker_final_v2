import 'package:diet_tracker/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';
import '../models/food_entry_model.dart';

class FoodDetailsPanel extends StatelessWidget {
  final Map<String, dynamic>? foodAnalysis;
  final bool isProcessing;
  final VoidCallback onRetake;
  final UserModel user;
  final File imageFile;
  final Function(FoodEntryModel) onAddToLog;

  const FoodDetailsPanel({
    super.key,
    required this.foodAnalysis,
    required this.isProcessing,
    required this.onRetake,
    required this.user,
    required this.imageFile,
    required this.onAddToLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingS),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: isProcessing || foodAnalysis == null
                ? _buildLoadingState()
                : _buildFoodDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
      ),
    );
  }

  Widget _buildFoodDetails(BuildContext context) {
    final name = foodAnalysis!['name']?.toString() ?? 'Tidak diketahui';
    final confidence =
        double.tryParse(foodAnalysis!['confidence']?.toString() ?? '0.0') ??
        0.0;
    final calories =
        double.tryParse(foodAnalysis!['calories']?.toString() ?? '0') ?? 0.0;
    final carbs =
        double.tryParse(foodAnalysis!['carbohydrates']?.toString() ?? '0') ??
        0.0;
    final proteins =
        double.tryParse(foodAnalysis!['proteins']?.toString() ?? '0') ?? 0.0;
    final fats =
        double.tryParse(foodAnalysis!['fats']?.toString() ?? '0') ?? 0.0;
    final servingSize = foodAnalysis!['serving_size']?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food name and confidence
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: _getConfidenceColor(confidence),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(confidence * 100).toStringAsFixed(0)}% yakin',
                          style: AppTheme.bodySmall.copyWith(
                            color: _getConfidenceColor(confidence),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Calories display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Column(
                  children: [
                    Text(
                      calories.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Serving size
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.backgroundNeutral,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXS),

                Expanded(
                  // 🔥 INI KUNCI UTAMANYA
                  child: Text(
                    'Porsi: $servingSize',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Nutrition breakdown
          Text(
            'Informasi Gizi',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Row(
            children: [
              Expanded(
                child: _buildNutritionCard(
                  'Karbohidrat',
                  '${carbs}g',
                  Icons.grain_rounded,
                  AppTheme.warningOrange,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Expanded(
                child: _buildNutritionCard(
                  'Protein',
                  '${proteins}g',
                  Icons.fitness_center_rounded,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Expanded(
                child: _buildNutritionCard(
                  'Lemak',
                  '${fats}g',
                  Icons.water_drop_rounded,
                  AppTheme.accentTeaGreen,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final foodEntry = FoodEntryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user.id,
                      foodName: name,
                      calories: calories,
                      carbohydrates: carbs,
                      proteins: proteins,
                      fats: fats,
                      consumedAt: DateTime.now(),
                      createdAt: DateTime.now(),
                      imagePath: imageFile.path,
                    );

                    // Save to Provider
                    await Provider.of<FoodProvider>(
                      context,
                      listen: false,
                    ).addFoodEntry(foodEntry);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$name Berhasil ditambahkan ke Log Makanan!',
                          ),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainNavigationScreen(user: user),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded),
                      const SizedBox(width: AppTheme.spacingS),
                      const Text(
                        'Simpan ke Log Makanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return AppTheme.successGreen;
    } else if (confidence >= 0.6) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.errorRed;
    }
  }
}
