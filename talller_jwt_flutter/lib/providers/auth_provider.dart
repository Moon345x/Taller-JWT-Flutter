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
  String? _name;
  String? _email;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String get displayName => _name?.isNotEmpty == true ? _name! : 'Sin nombre';
  String get displayEmail => _email?.isNotEmpty == true ? _email! : 'Sin email';
  bool get hasToken => _token?.isNotEmpty == true;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _setLoading(true);
    final token = await secureStorageService.getToken();
    final profile = await storageService.getProfile();
    _token = token;
    _name = profile.name;
    _email = profile.email;
    _isInitialized = true;
    _setLoading(false);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final result = await authService.login(email: email, password: password);
      final nameToSave = result.name ?? '';
      final emailToSave = result.email ?? email;

      await storageService.saveProfile(
        name: nameToSave,
        email: emailToSave,
      );
      await secureStorageService.saveToken(result.token);

      _token = result.token;
      _name = nameToSave;
      _email = emailToSave;
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
    _name = null;
    _email = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
