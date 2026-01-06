import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserStorage {
  static const _key = 'user_data';

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}
