import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserLocalStorage {
  static const _userKey = 'user_data';

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);

    if (jsonString == null) return null;

    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;

    return UserModel.fromJson(json);
  }

  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
