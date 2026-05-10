import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>((
  ref,
) {
  return SecureStorageDataSource();
});

class SecureStorageDataSource {
  static const _tokenKey = 'jwt_token';
  static const _guestModeKey = 'is_guest_mode';

  Future<void> saveGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, isGuest);
  }

  Future<bool> readGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      debugPrint('SecureStorage: Web detected. Saving token to SharedPreferences.');
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_tokenKey, token);
      debugPrint('SecureStorage: Save ${success ? 'successful' : 'failed'}. Key: flutter.$_tokenKey');
    } else {
      debugPrint('SecureStorage: Mobile detected. Saving token to FlutterSecureStorage.');
      const storage = FlutterSecureStorage();
      await storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> readToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      debugPrint('SecureStorage: Reading token from Web. Found: ${token != null ? 'YES' : 'NO'}');
      return token;
    } else {
      const storage = FlutterSecureStorage();
      return await storage.read(key: _tokenKey);
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: _tokenKey);
    }
  }
}
