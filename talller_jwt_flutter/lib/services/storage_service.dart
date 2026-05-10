import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  const UserProfile({this.name, this.email});

  final String? name;
  final String? email;
}

class StorageService {
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';

  Future<void> saveProfile({required String name, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
  }

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString(_nameKey),
      email: prefs.getString(_emailKey),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }
}
