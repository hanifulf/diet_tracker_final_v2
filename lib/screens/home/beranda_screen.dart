import 'package:diet_tracker/widgets/input_manual.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/food_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/calorie_progress_circle.dart';
import '../../widgets/macro_details_card.dart';
import '../../widgets/water_intake_card.dart';
import '../../widgets/food_history_list.dart';
import '../scan/food_logging_screen.dart';
import '../scan/scan_screen.dart';
import '../../providers/water_provider.dart';
import '../../models/water_intake_model.dart';

class BerandaScreen extends StatefulWidget {
  final UserModel user;

  const BerandaScreen({super.key, required this.user});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  bool _sortByCaloriesDesc = true;
  bool _sortByNewest = true;

  void _toggleSortByCalories() {
    setState(() {
      _sortByCaloriesDesc = !_sortByCaloriesDesc;
    });
  }

  void _toggleSortByTime() {
    setState(() {
      _sortByNewest = !_sortByNewest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final waterProvider = Provider.of<WaterProvider>(context);
    final currentCalories = foodProvider.totalTodayCalories;
    final currentCarbs = foodProvider.totalTodayCarbs;
    final currentProteins = foodProvider.totalTodayProteins;
    final currentFats = foodProvider.totalTodayFats;

    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and profile
                _buildHeader(),
                const SizedBox(height: AppTheme.spacingXL),

                // Calorie Progress + Macro Details side by side
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: AppTheme.cardDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian kiri: judul + circle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalori Harian',
                            style: AppTheme.headingSmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CalorieProgressCircle(
                              currentCalories: currentCalories,
                              targetCalories: widget.user.dailyCalorieTarget,
                              currentCarbs: currentCarbs,
                              currentProteins: currentProteins,
                              currentFats: currentFats,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppTheme.spacingL),

                      // Bagian kanan: rincian makro
                      Expanded(
                        child: MacroDetailsCard(
                          currentCarbs: currentCarbs,
                          currentProteins: currentProteins,
                          currentFats: currentFats,
                          targetCalories: widget.user.dailyCalorieTarget,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Water Intake
                WaterIntakeCard(
                  currentIntake: waterProvider.todayIntake,
                  targetIntake: widget.user.dailyWaterTarget,
                  onAddWater: _addWaterIntake,
                ),
                const SizedBox(height: AppTheme.spacingL),

                // ======================
                // Food History Section
                // ======================
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingL, // kiri
                    AppTheme.spacingS, // atas
                    AppTheme.spacingL, // kanan
                    AppTheme.spacingS, // bawah
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Makanan Hari Ini',
                        style: AppTheme.headingSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _sortByCaloriesDesc
                                  ? Icons.local_fire_department_rounded
                                  : Icons.local_fire_department_outlined,
                              color: AppTheme.primaryGreen,
                            ),
                            onPressed: _toggleSortByCalories,
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     _sortByNewest
                          //         ? Icons.access_time_filled_rounded
                          //         : Icons.access_time_outlined,
                          //     color: AppTheme.primaryGreen,
                          //   ),
                          //   onPressed: _toggleSortByTime,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Food History List
                FoodHistoryList(
                  entries: foodProvider.todayEntries,
                  sortByCaloriesDesc: _sortByCaloriesDesc,
                  sortByNewest: _sortByNewest,
                ),

                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodOptions,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${widget.user.name}!',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                'Semangat mencapai target hari ini!',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(30),
            image: widget.user.profileImagePath != null
                ? DecorationImage(
                    image: File(widget.user.profileImagePath!).existsSync()
                        ? FileImage(File(widget.user.profileImagePath!))
                        : AssetImage('assets/images/default_profile.png')
                              as ImageProvider,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child:
              widget.user.profileImagePath == null ||
                  !File(widget.user.profileImagePath!).existsSync()
              ? const Icon(Icons.person_rounded, size: 20, color: Colors.white)
              : null,
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data here
    });
  }

  void _addWaterIntake(double amount) {
    context.read<WaterProvider>().addWaterIntake(
      WaterIntakeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.user.id,
        amount: amount,
        consumedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ditambahkan ${amount.toInt()}ml air'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showAddFoodOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Tambah Makanan',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryGreen,
              ),
            ),

            // Scan Food Option
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppTheme.primaryGreen,
                ),
              ),
              title: const Text('Scan Makanan'),
              subtitle: const Text('Gunakan kamera untuk scan makanan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanScreen(user: widget.user),
                  ),
                );
              },
            ),

            // Manual Entry Option
            const SizedBox(height: AppTheme.spacingS),

            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeaGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppTheme.accentTeaGreen,
                ),
              ),
              title: const Text('Input Manual'),
              subtitle: const Text('Masukkan data makanan secara manual'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputManualScreen(
                      user: widget
                          .user, // kalau butuh data user, bisa lempar di sini
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }
}
