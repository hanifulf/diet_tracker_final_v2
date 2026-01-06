import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/food_entry_model.dart';

class FoodHistoryList extends StatelessWidget {
  final List<FoodEntryModel> entries;
  final bool sortByCaloriesDesc;
  final bool sortByNewest;

  const FoodHistoryList({
    super.key,
    required this.entries,
    required this.sortByCaloriesDesc,
    required this.sortByNewest,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    // 🔹 Sorting logika
    final sortedEntries = [...entries];

    if (sortByCaloriesDesc && !sortByNewest) {
      sortedEntries.sort((a, b) => b.calories.compareTo(a.calories));
    } else if (!sortByCaloriesDesc && sortByNewest) {
      sortedEntries.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    } else if (sortByCaloriesDesc && sortByNewest) {
      sortedEntries.sort((a, b) {
        final timeCompare = b.consumedAt.compareTo(a.consumedAt);
        if (timeCompare != 0) return timeCompare;
        return b.calories.compareTo(a.calories);
      });
    }

    return Column(
      children: sortedEntries
          .map((entry) => _buildFoodEntryCard(entry))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Belum ada makanan hari ini',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Mulai catat makanan kamu dengan menekan tombol + di bawah',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodEntryCard(FoodEntryModel entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Food icon/image placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: entry.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: entry.imagePath!.startsWith('/')
                        ? Image.file(File(entry.imagePath!), fit: BoxFit.cover)
                        : Image.asset(entry.imagePath!, fit: BoxFit.cover),
                  )
                : const Icon(
                    Icons.fastfood_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
          ),
          const SizedBox(width: AppTheme.spacingM),

          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.foodName,
                  style: AppTheme.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  _formatTime(entry.consumedAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),

                // Macro summary
                Row(
                  children: [
                    _buildMacroChip(
                      'K: ${entry.carbohydrates.toStringAsFixed(0)}g',
                      AppTheme.warningOrange,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    _buildMacroChip(
                      'P: ${entry.proteins.toStringAsFixed(0)}g',
                      AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    _buildMacroChip(
                      'L: ${entry.fats.toStringAsFixed(0)}g',
                      AppTheme.accentTeaGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.calories.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'kcal',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
