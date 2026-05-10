import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'services/storage_service.dart';
import 'widgets/auth_gate.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<SecureStorageService>(create: (_) => SecureStorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            storageService: context.read<StorageService>(),
            secureStorageService: context.read<SecureStorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Taller JWT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
