import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/food_entry_model.dart';

class HistoryFoodList extends StatelessWidget {
  final List<FoodEntryModel> entries;
  final Function(FoodEntryModel) onEntryTap;
  final Function(FoodEntryModel) onEntryDelete;

  const HistoryFoodList({
    super.key,
    required this.entries,
    required this.onEntryTap,
    required this.onEntryDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppTheme.spacingM),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildFoodEntryCard(context, entry);
      },
    );
  }

  Widget _buildFoodEntryCard(BuildContext context, FoodEntryModel entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final result = await showDialog<bool>(
          context: context, // pakai context dari parameter
          builder: (_) => AlertDialog(
            title: const Text('Hapus Makanan'),
            content: Text('Hapus "${entry.foodName}" dari riwayat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
        return result;
      },
      onDismissed: (direction) {
        onEntryDelete(entry);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${entry.foodName} dihapus')));
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => onEntryTap(entry),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: AppTheme.cardDecoration.copyWith(
            border: Border.all(
              color: AppTheme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Food image/icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: entry.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        child: entry.imagePath!.startsWith('/')
                            ? Image.file(
                                File(entry.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(entry.imagePath!, fit: BoxFit.cover),
                      )
                    : Icon(
                        _getFoodIcon(entry.foodName),
                        color: AppTheme.primaryGreen,
                        size: 28,
                      ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.foodName,
                            style: AppTheme.bodyLarge.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(entry.consumedAt),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingS),

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

              const SizedBox(width: AppTheme.spacingM),

              // Calories and arrow
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

                  const SizedBox(height: AppTheme.spacingS),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
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

  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();

    if (name.contains('nasi') || name.contains('rice')) {
      return Icons.rice_bowl_rounded;
    } else if (name.contains('ayam') || name.contains('chicken')) {
      return Icons.set_meal_rounded;
    } else if (name.contains('salad') || name.contains('sayur')) {
      return Icons.eco_rounded;
    } else if (name.contains('smoothie') || name.contains('jus')) {
      return Icons.local_drink_rounded;
    } else if (name.contains('pasta') || name.contains('mie')) {
      return Icons.ramen_dining_rounded;
    } else if (name.contains('burger') || name.contains('sandwich')) {
      return Icons.lunch_dining_rounded;
    } else if (name.contains('pizza')) {
      return Icons.local_pizza_rounded;
    } else if (name.contains('cake') || name.contains('kue')) {
      return Icons.cake_rounded;
    } else {
      return Icons.fastfood_rounded;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
