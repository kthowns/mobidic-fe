import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JS('TossBridge')
external TossBridgeObject? get _tossBridge;

@JS()
extension type TossBridgeObject._(JSObject _) implements JSObject {
  external JSBoolean isTossEnvironment();
  @JS('Storage')
  external TossStorage get storage;
  external JSPromise<JSAny?> closeView();
}

@JS()
extension type TossStorage._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> setItem(JSString key, JSString value);
  external JSPromise<JSString?> getItem(JSString key);
  external JSPromise<JSAny?> removeItem(JSString key);
  external JSPromise<JSAny?> clearItems();
}

/// 웹 / 앱인토스 웹뷰 전용 TossBridge 정석 구현체
class TossBridgeImpl {
  /// 현재 앱인토스 웹뷰 환경인지 확인
  static bool get isTossEnvironment {
    try {
      return _tossBridge?.isTossEnvironment().toDart ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 앱 닫기 / 뒤로가기 연동
  static void closeApp() {
    if (isTossEnvironment) {
      try {
        _tossBridge?.closeView();
      } catch (e) {
        debugPrint('TossBridge closeApp error: $e');
      }
    }
  }

  /// 토스 네이티브 영구 저장소 - 저장
  static Future<bool> saveStorage(String key, String value) async {
    try {
      if (isTossEnvironment && _tossBridge != null) {
        await _tossBridge!.storage.setItem(key.toJS, value.toJS).toDart;
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      debugPrint('TossBridge saveStorage error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(key, value);
      } catch (_) {
        return false;
      }
    }
  }

  /// 토스 네이티브 영구 저장소 - 읽기
  static Future<String?> readStorage(String key) async {
    try {
      if (isTossEnvironment && _tossBridge != null) {
        final result = await _tossBridge!.storage.getItem(key.toJS).toDart;
        final val = result?.toDart;
        if (val != null && val.isNotEmpty) return val;
      }

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('TossBridge readStorage error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } catch (_) {
        return null;
      }
    }
  }

  /// 토스 네이티브 영구 저장소 - 삭제
  static Future<void> deleteStorage(String key) async {
    try {
      if (isTossEnvironment && _tossBridge != null) {
        await _tossBridge!.storage.removeItem(key.toJS).toDart;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('TossBridge deleteStorage error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (_) {}
    }
  }
}
