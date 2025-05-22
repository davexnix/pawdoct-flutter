import 'dart:convert';
import 'package:pawdoct/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  factory StorageService() => _instance;

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get authToken => _prefs.getString('auth_token');

  Future<void> setAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<bool> removeAuthToken() async {
    return _prefs.remove('auth_token');
  }

  UserModel? get user {
    final jsonString = _prefs.getString('user');
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(UserModel user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> removeUser() async {
    await _prefs.remove('user');
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
