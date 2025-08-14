import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  
  bool _isAuthenticated = false;
  String? _token;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  
  AuthProvider() {
    _checkAuthentication();
  }
  
  Future<void> _checkAuthentication() async {
    _token = await _storage.read(key: 'token');
    _isAuthenticated = _token != null;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    try {
      final token = await _authService.login(email, password);
      await _storage.write(key: 'token', value: token);
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    try {
      final token = await _authService.register(name, email, password);
      await _storage.write(key: 'token', value: token);
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}