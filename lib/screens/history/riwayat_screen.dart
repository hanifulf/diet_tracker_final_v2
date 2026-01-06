import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/food_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/food_entry_model.dart';
import '../../models/water_intake_model.dart';
import '../../models/weight_entry_model.dart';
import '../../widgets/history_date_selector.dart';
import '../../widgets/daily_summary_card.dart';
import '../../widgets/history_food_list.dart';
import '../../widgets/history_filter_chips.dart';
import '../../providers/water_provider.dart';

class RiwayatScreen extends StatefulWidget {
  final UserModel user;

  const RiwayatScreen({super.key, required this.user});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // // Dummy data (water & weight only)
  // late List<WaterIntakeModel> _waterIntakes;
  // late List<WeightEntryModel> _weightEntries;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeSampleData();
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // void _initializeSampleData() {
  //   _waterIntakes = [
  //     WaterIntakeModel(
  //       id: '1',
  //       userId: widget.user.id,
  //       amount: 250,
  //       consumedAt: DateTime.now().subtract(const Duration(hours: 1)),
  //       createdAt: DateTime.now(),
  //     ),
  //     WaterIntakeModel(
  //       id: '2',
  //       userId: widget.user.id,
  //       amount: 500,
  //       consumedAt: DateTime.now().subtract(const Duration(hours: 3)),
  //       createdAt: DateTime.now(),
  //     ),
  //   ];

  //   _weightEntries = [
  //     WeightEntryModel(
  //       id: '1',
  //       userId: widget.user.id,
  //       weight: 70,
  //       recordedAt: DateTime.now(),
  //       createdAt: DateTime.now(),
  //     ),
  //   ];
  // }

  // ================= FILTER & SUMMARY =================

  List<FoodEntryModel> _getFilteredFoodEntries(
    List<FoodEntryModel> allEntries,
  ) {
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    var entries = allEntries.where((e) {
      return e.consumedAt.isAfter(startOfDay) &&
          e.consumedAt.isBefore(endOfDay);
    }).toList();

    if (_searchController.text.isNotEmpty) {
      entries = entries
          .where(
            (e) => e.foodName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return entries..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
  }

  double _getTotalCalories(List<FoodEntryModel> entries) {
    return entries.fold(0, (sum, e) => sum + e.calories);
  }

  // double _getTotalWater() {
  //   final startOfDay = DateTime(
  //     _selectedDate.year,
  //     _selectedDate.month,
  //     _selectedDate.day,
  //   );
  //   final endOfDay = startOfDay.add(const Duration(days: 1));

  //   return _waterIntakes
  //       .where(
  //         (e) =>
  //             e.consumedAt.isAfter(startOfDay) &&
  //             e.consumedAt.isBefore(endOfDay),
  //       )
  //       .fold(0, (sum, e) => sum + e.amount);
  // }
  /// ✅ WATER DIAMBIL LANGSUNG DARI WATER PROVIDER
  double _getTotalWater(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();

    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return waterProvider.waterIntakes
        .where(
          (e) =>
              e.consumedAt.isAfter(startOfDay) &&
              e.consumedAt.isBefore(endOfDay),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }
  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final filteredEntries = _getFilteredFoodEntries(foodProvider.foodEntries);

    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Riwayat',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryGreen),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryGreen),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: HistoryDateSelector(
              selectedDate: _selectedDate,
              onDateChanged: (d) => setState(() => _selectedDate = d),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: DailySummaryCard(
              date: _selectedDate,
              totalCalories: _getTotalCalories(filteredEntries),
              targetCalories: widget.user.dailyCalorieTarget,
              totalWater: _getTotalWater(context),
              targetWater: widget.user.dailyWaterTarget,
              foodCount: filteredEntries.length,
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: HistoryFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (f) => setState(() => _selectedFilter = f),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Expanded(
            child: filteredEntries.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                    ),
                    child: HistoryFoodList(
                      entries: filteredEntries,
                      onEntryTap: _onFoodEntryTap,
                      onEntryDelete: _onFoodEntryDelete,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  void _onFoodEntryDelete(FoodEntryModel entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Makanan'),
        content: Text('Hapus "${entry.foodName}" dari riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FoodProvider>().deleteFoodEntry(entry.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${entry.foodName} dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _onFoodEntryTap(FoodEntryModel entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _buildFoodDetail(entry),
    );
  }

  // ================= WIDGETS =================

  Widget _buildEmptyState() {
    return const Center(child: Text('Tidak ada riwayat makanan'));
  }

  Widget _buildFoodDetail(FoodEntryModel entry) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.foodName, style: AppTheme.headingMedium),
          const SizedBox(height: 10),
          Text('${entry.calories} kcal'),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cari Makanan'),
        content: TextField(controller: _searchController),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }
}
