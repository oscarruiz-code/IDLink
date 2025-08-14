import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:8080/api'; // Cambia esto según tu configuración
  final _storage = const FlutterSecureStorage();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
  }
  
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }
  
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
  }
}