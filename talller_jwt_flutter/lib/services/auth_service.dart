import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthResult {
  const AuthResult({required this.token});

  final String token;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const String _endpoint = 'https://fakestoreapi.com/auth/login';

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(_endpoint);
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        _extractError(response.body) ?? 'Credenciales incorrectas',
      );
    }

    final decoded = _decodeJson(response.body);
    final token = _extractToken(decoded);
    if (token == null || token.isEmpty) {
      throw const AuthException('No se recibio token');
    }

    return AuthResult(token: token);
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    throw const AuthException('Respuesta invalida del servidor');
  }

  String? _extractToken(Map<String, dynamic> json) {
    final value = json['token'];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}
    return null;
  }

}
