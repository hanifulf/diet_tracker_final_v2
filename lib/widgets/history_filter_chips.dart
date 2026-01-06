import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HistoryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const HistoryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Semua Riwayat Makanan', 'icon': Icons.all_inclusive_rounded},
      // Bisa tambah filter lain di sini
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Column(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter['label'];

          return Container(
            width: double.infinity, // Buat chip full width
            margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: FilterChip(
              label: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // icon + text di tengah
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    filter['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter['label'] as String);
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppTheme.primaryGreen,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withOpacity(0.3),
              ),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}
