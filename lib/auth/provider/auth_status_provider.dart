import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인증 상태와 관련된 신호를 관리하는 프로바이더입니다.
/// 401 Unauthorized 에러 발생 시 신호를 보내는 용도로 사용됩니다.
final authSignalProvider = StateProvider<AuthSignal?>((ref) => null);

enum AuthSignal {
  unauthorized, // 401 에러 발생
}
