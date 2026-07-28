import 'toss_bridge_stub.dart'
    if (dart.library.js_interop) 'toss_bridge_web.dart';

/// 앱인토스(Apps in Toss) JS SDK 통합 브릿지
class TossBridge {
  /// 현재 앱인토스 웹뷰 환경인지 여부 확인
  static bool get isTossEnvironment => TossBridgeImpl.isTossEnvironment;

  /// 앱 닫기 / 뒤로가기 연동
  static void closeApp() => TossBridgeImpl.closeApp();

  /// 토스 네이티브 영구 저장소 - 저장
  static Future<bool> saveStorage(String key, String value) =>
      TossBridgeImpl.saveStorage(key, value);

  /// 토스 네이티브 영구 저장소 - 읽기
  static Future<String?> readStorage(String key) =>
      TossBridgeImpl.readStorage(key);

  /// 토스 네이티브 영구 저장소 - 삭제
  static Future<void> deleteStorage(String key) =>
      TossBridgeImpl.deleteStorage(key);
}
