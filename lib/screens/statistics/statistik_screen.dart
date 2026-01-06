import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/food_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/calorie_chart_card.dart';
import '../../widgets/weight_progress_card.dart';
import '../../widgets/weight_trend_chart_card.dart';

import '../../services/weight_history_storage.dart';
import '../../services/user_local_storage.dart';

class StatistikScreen extends StatefulWidget {
  final UserModel user;

  const StatistikScreen({super.key, required this.user});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  String _selectedTimeRange = 'Mingguan';
  late double _currentWeight;
  late Future<List<Map<String, dynamic>>> _weightHistoryFuture;

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.user.currentWeight;
    _weightHistoryFuture = _initWeightHistory();
  }

  Future<List<Map<String, dynamic>>> _initWeightHistory() async {
    final history = await WeightHistoryStorage.load();

    // 🔥 SINKRONISASI PERTAMA
    if (history.isEmpty) {
      await WeightHistoryStorage.add(widget.user.currentWeight);
      return WeightHistoryStorage.load();
    }

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final todayEntries = foodProvider.todayEntries;

    final List<Map<String, dynamic>> calorieData = todayEntries.isEmpty
        ? [
            {'day': '-', 'calories': 0.0},
          ]
        : todayEntries.map((entry) {
            return {
              'day': entry.foodName.length > 5
                  ? '${entry.foodName.substring(0, 5)}..'
                  : entry.foodName,
              'full_name': entry.foodName,
              'calories': entry.calories,
            };
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Statistik',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryGreen),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === CALORIE CHART ===
              CalorieChartCard(
                title: 'Kalori Per Makanan',
                timeRange: 'Hari Ini',
                data: calorieData,
              ),

              const SizedBox(height: AppTheme.spacingL),

              // === WEIGHT PROGRESS ===
              WeightProgressCard(
                currentWeight: _currentWeight,
                targetWeight: widget.user.targetWeight,
                onWeightUpdated: _onWeightUpdated,
              ),

              const SizedBox(height: AppTheme.spacingL),

              // === WEIGHT TREND (REAL DATA) ===
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _weightHistoryFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.data!.isEmpty) {
                    return WeightTrendChartCard(
                      title: 'Tren Berat Badan',
                      timeRange: _selectedTimeRange,
                      data: const [],
                      targetWeight: widget.user.targetWeight,
                    );
                  }

                  return WeightTrendChartCard(
                    title: 'Tren Berat Badan',
                    timeRange: _selectedTimeRange,
                    data: snapshot.data!,
                    targetWeight: widget.user.targetWeight,
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _weightHistoryFuture = WeightHistoryStorage.load();
    });
  }

  // 🔥 INI INTI SINKRONISASI
  void _onWeightUpdated(double newWeight) async {
    // 1. simpan histori (tanggal + berat)
    await WeightHistoryStorage.add(newWeight);

    // 2. update user
    final updatedUser = widget.user.copyWith(
      currentWeight: newWeight,
      updatedAt: DateTime.now(),
    );
    await UserLocalStorage.saveUser(updatedUser);

    // 3. refresh UI
    setState(() {
      _currentWeight = newWeight;
      widget.user.currentWeight = newWeight;
      _weightHistoryFuture = WeightHistoryStorage.load();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berat badan diperbarui: ${newWeight.toStringAsFixed(1)} kg',
        ),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
