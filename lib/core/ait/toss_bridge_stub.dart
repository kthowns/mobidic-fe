/// 모바일 (Android / iOS) 네이티브용 TossBridge Stub
class TossBridgeImpl {
  static bool get isTossEnvironment => false;

  static void closeApp() {}

  static Future<bool> saveStorage(String key, String value) async => false;

  static Future<String?> readStorage(String key) async => null;

  static Future<void> deleteStorage(String key) async {}
}
