import 'dart:js_interop';
import 'package:shared_preferences/shared_preferences.dart';

@JS('Ait')
external AitObject? get _aitObject;

@JS('Granite')
external GraniteObject? get _graniteObject;

@JS('toss')
external JSObject? get _tossObject;

@JS()
extension type AitObject._(JSObject _) implements JSObject {
  @JS('Storage')
  external AitStorage? get storage;
}

@JS()
extension type GraniteObject._(JSObject _) implements JSObject {
  @JS('Storage')
  external GraniteStorage? get storage;
}

@JS()
extension type AitStorage._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> setItem(JSString key, JSString value);
  external JSPromise<JSString?> getItem(JSString key);
  external JSPromise<JSAny?> removeItem(JSString key);
}

@JS()
extension type GraniteStorage._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> setItem(JSString key, JSString value);
  external JSPromise<JSString?> getItem(JSString key);
  external JSPromise<JSAny?> removeItem(JSString key);
}

@JS()
extension type TossObject._(JSObject _) implements JSObject {
  external void closeApp();
  external void closeView();
}

/// 웹 / 앱인토스 웹뷰 전용 TossBridge 정석 구현체
class TossBridgeImpl {
  /// 현재 앱인토스 웹뷰 환경인지 확인
  static bool get isTossEnvironment =>
      _aitObject != null || _graniteObject != null || _tossObject != null;

  /// 앱 닫기 / 뒤로가기 연동
  static void closeApp() {
    if (isTossEnvironment) {
      try {
        final toss = _tossObject as TossObject?;
        try {
          toss?.closeView();
        } catch (_) {}
        try {
          toss?.closeApp();
        } catch (_) {}
      } catch (_) {}
    }
  }

  /// 토스 네이티브 영구 저장소 - 저장
  static Future<bool> saveStorage(String key, String value) async {
    try {
      final aitStorage = _aitObject?.storage;
      final graniteStorage = _graniteObject?.storage;

      if (aitStorage != null) {
        await aitStorage.setItem(key.toJS, value.toJS).toDart;
        return true;
      } else if (graniteStorage != null) {
        await graniteStorage.setItem(key.toJS, value.toJS).toDart;
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
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
      final aitStorage = _aitObject?.storage;
      final graniteStorage = _graniteObject?.storage;

      if (aitStorage != null) {
        final result = await aitStorage.getItem(key.toJS).toDart;
        final val = result?.toDart;
        if (val != null && val.isNotEmpty) return val;
      } else if (graniteStorage != null) {
        final result = await graniteStorage.getItem(key.toJS).toDart;
        final val = result?.toDart;
        if (val != null && val.isNotEmpty) return val;
      }

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
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
      final aitStorage = _aitObject?.storage;
      final graniteStorage = _graniteObject?.storage;

      if (aitStorage != null) {
        await aitStorage.removeItem(key.toJS).toDart;
      } else if (graniteStorage != null) {
        await graniteStorage.removeItem(key.toJS).toDart;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (_) {}
    }
  }
}
