import 'dart:js_interop';

@JS('eval')
external JSAny? _jsEval(JSString code);

/// 앱인토스(Apps in Toss) JS SDK 전용 브릿지
class TossBridge {
  /// 현재 앱인토스 웹뷰 환경(Ait, Granite, 또는 toss 객체 존재 여부)인지 확인
  static bool get isTossEnvironment {
    try {
      final code =
          "typeof window !== 'undefined' && ((typeof window.Ait !== 'undefined' && window.Ait !== null) || (typeof window.Granite !== 'undefined' && window.Granite !== null) || (typeof window.toss !== 'undefined' && window.toss !== null))";
      final res = _jsEval(code.toJS);
      return (res as JSBoolean?)?.toDart ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 앱 닫기 / 뒤로가기 연동
  static void closeApp() {
    if (isTossEnvironment) {
      try {
        _jsEval("if (window.toss && window.toss.closeApp) { window.toss.closeApp(); }".toJS);
      } catch (_) {}
    }
  }

  /// 토스 네이티브 영구 저장소 - 저장
  static Future<bool> saveStorage(String key, String value) async {
    try {
      final escapedKey = key.replaceAll("'", "\\'");
      final escapedValue = value.replaceAll("'", "\\'");
      final code = '''
        (async () => {
          if (window.Ait && window.Ait.Storage) {
            await window.Ait.Storage.setItem('$escapedKey', '$escapedValue');
            return true;
          } else if (window.Granite && window.Granite.Storage) {
            await window.Granite.Storage.setItem('$escapedKey', '$escapedValue');
            return true;
          }
          return false;
        })()
      ''';
      final promise = _jsEval(code.toJS) as JSPromise;
      final res = await promise.toDart;
      return (res as JSBoolean?)?.toDart ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 토스 네이티브 영구 저장소 - 읽기
  static Future<String?> readStorage(String key) async {
    try {
      final escapedKey = key.replaceAll("'", "\\'");
      final code = '''
        (async () => {
          if (window.Ait && window.Ait.Storage) {
            return await window.Ait.Storage.getItem('$escapedKey');
          } else if (window.Granite && window.Granite.Storage) {
            return await window.Granite.Storage.getItem('$escapedKey');
          }
          return null;
        })()
      ''';
      final promise = _jsEval(code.toJS) as JSPromise;
      final res = await promise.toDart;
      return (res as JSString?)?.toDart;
    } catch (e) {
      return null;
    }
  }

  /// 토스 네이티브 영구 저장소 - 삭제
  static Future<void> deleteStorage(String key) async {
    try {
      final escapedKey = key.replaceAll("'", "\\'");
      final code = '''
        (async () => {
          if (window.Ait && window.Ait.Storage) {
            await window.Ait.Storage.removeItem('$escapedKey');
          } else if (window.Granite && window.Granite.Storage) {
            await window.Granite.Storage.removeItem('$escapedKey');
          }
        })()
      ''';
      final promise = _jsEval(code.toJS) as JSPromise;
      await promise.toDart;
    } catch (_) {}
  }
}
