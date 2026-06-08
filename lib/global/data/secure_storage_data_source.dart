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
