import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry_model.dart';

class FoodProvider extends ChangeNotifier {
  static const String _storageKey = 'food_entries';

  List<FoodEntryModel> _foodEntries = [];
  bool _isLoading = false;

  // ================= GETTERS =================

  List<FoodEntryModel> get foodEntries => List.unmodifiable(_foodEntries);
  bool get isLoading => _isLoading;

  List<FoodEntryModel> get todayEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _foodEntries.where((entry) {
      final entryDate = DateTime(
        entry.consumedAt.year,
        entry.consumedAt.month,
        entry.consumedAt.day,
      );
      return entryDate == today;
    }).toList();
  }

  double get totalTodayCalories =>
      todayEntries.fold(0, (sum, e) => sum + e.calories);

  double get totalTodayCarbs =>
      todayEntries.fold(0, (sum, e) => sum + e.carbohydrates);

  double get totalTodayProteins =>
      todayEntries.fold(0, (sum, e) => sum + e.proteins);

  double get totalTodayFats => todayEntries.fold(0, (sum, e) => sum + e.fats);

  // ================= CONSTRUCTOR =================

  FoodProvider() {
    loadEntries();
  }

  // ================= CRUD =================

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List decoded = jsonDecode(jsonString);
        _foodEntries = decoded.map((e) => FoodEntryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error loading food entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFoodEntry(FoodEntryModel entry) async {
    _foodEntries.add(entry);
    await _saveToPrefs();
    notifyListeners();
  }

  /// ✅ INI YANG KAMU BUTUHKAN UNTUK RIWAYAT
  Future<void> deleteFoodEntry(String id) async {
    _foodEntries.removeWhere((entry) => entry.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  /// (Opsional) update / edit
  Future<void> updateFoodEntry(FoodEntryModel updatedEntry) async {
    final index = _foodEntries.indexWhere((e) => e.id == updatedEntry.id);

    if (index != -1) {
      _foodEntries[index] = updatedEntry;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  // ================= STORAGE =================

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_foodEntries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('❌ Error saving food entries: $e');
    }
  }
}
