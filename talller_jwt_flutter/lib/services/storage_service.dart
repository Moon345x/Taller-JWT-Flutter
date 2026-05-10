import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  const UserProfile({this.username});

  final String? username;
}

class StorageService {
  static const String _usernameKey = 'username';

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      username: prefs.getString(_usernameKey),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
  }
}
