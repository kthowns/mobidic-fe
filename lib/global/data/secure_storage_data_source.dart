import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/ait/toss_bridge.dart';

final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>((
  ref,
) {
  return SecureStorageDataSource();
});

/// 순수 Key-Value 기반 영구 저장소 Data Source
class SecureStorageDataSource {
  /// 범용 Key-Value 저장
  Future<void> save(String key, String value) async {
    if (!kIsWeb) {
      // 1. 모바일 앱 (안드로이드 / iOS) -> FlutterSecureStorage
      const storage = FlutterSecureStorage();
      await storage.write(key: key, value: value);
    } else if (TossBridge.isTossEnvironment) {
      // 2. 앱인토스 웹뷰 환경 -> 토스 네이티브 Storage SDK (미지원 시 SharedPreferences 자동 폴백)
      final success = await TossBridge.saveStorage(key, value);
      if (!success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      }
      debugPrint('SecureStorage (Toss): Save ${success ? 'successful (Native)' : 'successful (SharedPreferences Fallback)'} for key: $key');
    } else {
      // 3. 순수 웹 브라우저 (Chrome, Safari 등) -> SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  /// 범용 Key-Value 읽기
  Future<String?> read(String key) async {
    if (!kIsWeb) {
      const storage = FlutterSecureStorage();
      return await storage.read(key: key);
    } else if (TossBridge.isTossEnvironment) {
      final value = await TossBridge.readStorage(key);
      if (value != null && value.isNotEmpty) return value;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  /// 범용 Key-Value 삭제
  Future<void> delete(String key) async {
    if (!kIsWeb) {
      const storage = FlutterSecureStorage();
      await storage.delete(key: key);
    } else if (TossBridge.isTossEnvironment) {
      await TossBridge.deleteStorage(key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }
}
