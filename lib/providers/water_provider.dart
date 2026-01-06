import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_intake_model.dart';

class WaterProvider with ChangeNotifier {
  final List<WaterIntakeModel> _waterIntakes = [];

  /// =====================
  /// CONSTRUCTOR
  /// =====================
  WaterProvider() {
    _loadFromPrefs();
  }

  /// =====================
  /// GETTERS
  /// =====================

  /// Semua data air (dipakai di Riwayat)
  List<WaterIntakeModel> get waterIntakes => List.unmodifiable(_waterIntakes);

  /// Total air hari ini (dipakai di Beranda)
  double get todayIntake {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _waterIntakes
        .where(
          (e) =>
              e.consumedAt.isAfter(startOfDay) &&
              e.consumedAt.isBefore(endOfDay),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// =====================
  /// ACTIONS
  /// =====================

  /// Tambah minum
  Future<void> addWaterIntake(WaterIntakeModel intake) async {
    _waterIntakes.add(intake);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Hapus minum
  Future<void> deleteWaterIntake(String id) async {
    _waterIntakes.removeWhere((e) => e.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Reset data (opsional)
  Future<void> clear() async {
    _waterIntakes.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  /// =====================
  /// SHARED PREFERENCES
  /// =====================

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('waterIntakes');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _waterIntakes.clear();
      _waterIntakes.addAll(
        jsonList
            .map((e) => WaterIntakeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _waterIntakes.map((e) => e.toJson()).toList();
    await prefs.setString('waterIntakes', json.encode(jsonList));
  }
}
