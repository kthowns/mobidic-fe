import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/data/secure_storage_data_source.dart';
import 'package:mobidic/provider/auth_status_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mobidic.kthowns.cloud',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ),
  );

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);
@override
void onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  final requiresAuth = options.extra['auth'] == true;
  debugPrint('Dio Request: [${options.method}] ${options.uri}');
  debugPrint('Requires Auth: $requiresAuth');

  if (requiresAuth) {
    try {
      String? token = await ref
          .read(secureStorageDataSourceProvider)
          .readToken();

      debugPrint('Retrieved Token: ${token != null ? 'EXISTS (${token.substring(0, 10)}...)' : 'NULL'}');

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('Authorization Header Added');
      } else {
        debugPrint('Warning: Token is NULL even though auth is required');
      }
    } catch (e) {
      debugPrint('토큰 읽기 실패: $e');
      throw Exception('토큰을 읽는 중 오류가 발생했습니다.');
    }
  }

  handler.next(options);
}

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 직접 AuthViewModel을 호출하는 대신 신호를 보냅니다.
      ref.read(authSignalProvider.notifier).state = AuthSignal.unauthorized;
    }

    handler.next(err);
  }
}
