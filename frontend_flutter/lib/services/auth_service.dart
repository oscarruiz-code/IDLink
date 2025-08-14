import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  Future<String> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Error al iniciar sesión: ${response.statusCode}');
    }
  }
  
  Future<String> register(String name, String email, String password) async {
    final response = await _apiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }
  
  Future<bool> validateToken(String token) async {
    try {
      final response = await _apiService.get('/auth/validate');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Incluso si falla el logout en el servidor, continuamos con el proceso local
      print('Error en logout: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _apiService.get('/auth/user');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener información del usuario');
    }
  }
}