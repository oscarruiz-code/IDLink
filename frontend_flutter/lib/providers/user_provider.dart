import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  List<dynamic>? _userAccesses;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  List<dynamic>? get userAccesses => _userAccesses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<void> getUserProfile() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _apiService.get('/users/profile');
      
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.body);
        notifyListeners();
      } else {
        setError('Error al obtener el perfil del usuario');
      }
    } catch (e) {
      setError('Error de conexión: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> getUserAccesses() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _apiService.get('/users/accesses');
      
      if (response.statusCode == 200) {
        _userAccesses = json.decode(response.body);
        notifyListeners();
      } else {
        setError('Error al obtener los accesos del usuario');
      }
    } catch (e) {
      setError('Error de conexión: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _apiService.put(
        '/users/profile',
        body: userData,
      );
      
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.body);
        notifyListeners();
        return true;
      } else {
        setError('Error al actualizar el perfil');
        return false;
      }
    } catch (e) {
      setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  Future<bool> shareAccess(String email, String accessType, DateTime expirationDate) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _apiService.post(
        '/accesses/share',
        body: {
          'email': email,
          'accessType': accessType,
          'expirationDate': expirationDate.toIso8601String(),
        },
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        setError('Error al compartir acceso');
        return false;
      }
    } catch (e) {
      setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  Future<bool> revokeAccess(String accessId) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _apiService.delete('/accesses/$accessId');
      
      if (response.statusCode == 200) {
        // Actualizar la lista de accesos después de revocar uno
        await getUserAccesses();
        return true;
      } else {
        setError('Error al revocar acceso');
        return false;
      }
    } catch (e) {
      setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
}