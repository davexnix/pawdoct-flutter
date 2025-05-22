import 'package:flutter/material.dart';
import 'package:pawdoct/models/user_model.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:pawdoct/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null && _token != null;
  String? get token => _token;

  AuthProvider() {
    _loadUserAndToken();
  }

  Future<void> _loadUserAndToken() async {
    final prefs = StorageService();
    _token = prefs.authToken;
    _user = prefs.user;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = StorageService().authToken;
    if (token == null) {
      await logout(api: false);
      return;
    }

    try {
      final req = await ApiService().dio.get('/auth/me');
      if (req.statusCode == 200) {
        _user = UserModel.fromJson(req.data);
      }
    } catch (_) {
      logout(api: false);
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final data = await ApiService().login(username, password);

      final token = data['token'];
      final user = data['user'];

      await StorageService().setAuthToken(token);
      await StorageService().setUser(user);

      _user = user;
      _token = token;
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout({bool api = true}) async {
    try {
      if (api) {
        await ApiService().logout();
      }
    } finally {
      _user = null;
      _token = null;
      await StorageService().clear();
      notifyListeners();
    }
  }
}