import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthResult {
  const AuthResult({
    required this.token,
    this.name,
    this.email,
  });

  final String token;
  final String? name;
  final String? email;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const String _endpoint =
      'https://parking.visiontic.com.co/api/login';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_endpoint);
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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

    final name = _pickString(decoded, ['name', 'nombre']);
    final responseEmail = _pickString(decoded, ['email']);

    return AuthResult(
      token: token,
      name: name,
      email: responseEmail,
    );
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
    return _pickString(json, ['token', 'access_token', 'accessToken', 'jwt']);
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

  String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }
}
