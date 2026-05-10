import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.authService,
    required this.storageService,
    required this.secureStorageService,
  });

  final AuthService authService;
  final StorageService storageService;
  final SecureStorageService secureStorageService;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _username;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String get displayUsername =>
      _username?.isNotEmpty == true ? _username! : 'Sin usuario';
  bool get hasToken => _token?.isNotEmpty == true;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _setLoading(true);
    final token = await secureStorageService.getToken();
    final profile = await storageService.getProfile();
    _token = token;
    _username = profile.username;
    _isInitialized = true;
    _setLoading(false);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final result =
          await authService.login(username: username, password: password);

      await storageService.saveUsername(username);
      await secureStorageService.saveToken(result.token);

      _token = result.token;
      _username = username;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error de red, intenta de nuevo';
    }
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _errorMessage = null;
    _setLoading(true);
    await storageService.clear();
    await secureStorageService.clearAll();
    _token = null;
    _username = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
