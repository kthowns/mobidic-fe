import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mobidic/view/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //usePathUrlStrategy();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await _checkForUpdate();

  runApp(ProviderScope(child: MyApp()));
}

Future<void> _checkForUpdate() async {
  if (kIsWeb || !Platform.isAndroid) {
    return;
  }
  try {
    // 1. 업데이트 가능 여부 확인
    AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
    print("로그 - 상태: ${updateInfo.updateAvailability}");
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      // 2. 업데이트 수행
      // Immediate: 강제 업데이트 (전체 화면)
      // Flexible: 선택적 업데이트 (백그라운드 다운로드)
      await InAppUpdate.performImmediateUpdate();
    }
  } catch (e) {
    // 에러 처리 (로그 기록 등)
    print("업데이트 체크 실패: $e");
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(routerConfig: router, title: 'Mobidic');
  }
}
