import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeightHistoryStorage {
  static const _key = 'weight_history';

  /// load -> SELALU return List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    final history = decoded.map<Map<String, dynamic>>((item) {
      final date = DateTime.parse(item['date']);

      // 🔥 normalisasi tanggal (buang jam)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      return {
        'date': normalizedDate,
        'weight': (item['weight'] as num).toDouble(),
      };
    }).toList();

    // 🔥 pastikan urut berdasarkan tanggal
    history.sort((a, b) {
      final d1 = a['date'] as DateTime;
      final d2 = b['date'] as DateTime;
      return d1.compareTo(d2);
    });

    return history;
  }

  /// add weight per hari (ANTI DUPLIKAT)
  static Future<void> add(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await load();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 🔥 cek apakah hari ini sudah ada
    final index = history.indexWhere((item) {
      final date = item['date'] as DateTime;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    });

    if (index >= 0) {
      // update
      history[index]['weight'] = weight;
    } else {
      // tambah baru
      history.add({'date': today, 'weight': weight});
    }

    final encoded = history.map((item) {
      return {
        'date': (item['date'] as DateTime).toIso8601String(),
        'weight': item['weight'],
      };
    }).toList();

    await prefs.setString(_key, jsonEncode(encoded));
  }
}
