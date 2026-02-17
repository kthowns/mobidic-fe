import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageDataSource {
  static const _tokenKey = 'jwt_token';
  static const _memberId = 'member_id';

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> readToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
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

  Future<void> saveMemberId(String memberId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_memberId, memberId);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: _memberId, value: memberId);
    }
  }

  Future<String?> readMemberId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_memberId);
    } else {
      const storage = FlutterSecureStorage();
      return await storage.read(key: _memberId);
    }
  }

  Future<void> deleteMemberId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_memberId);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: _memberId);
    }
  }
}