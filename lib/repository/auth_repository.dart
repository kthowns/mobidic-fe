import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/api/dio.dart';
import 'package:mobidic/data/secure_storage_data_source.dart';
import 'package:mobidic/dto/login_dto.dart';
import 'package:mobidic/dto/signup_dto.dart';
import 'package:mobidic/model/term.dart';
import 'package:mobidic/repository/repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorageDataSource = ref.read(secureStorageDataSourceProvider);
  final dio = ref.read(dioProvider);
  return AuthRepository(secureStorageDataSource, dio);
});

class AuthRepository extends Repository {
  final SecureStorageDataSource _secureStorageDataSource;
  final Dio _dio;

  AuthRepository(this._secureStorageDataSource, this._dio);

  Future<List<Term>> getTerms() async {
    final url = ApiUrl.terms.url;

    return await dioRequestToList<Term>(
      url: url,
      action: () => _dio.get(url),
      fromJson: Term.fromJson,
    );
  }

  Future<LoginResponse> login(LoginRequest request) {
    final url = ApiUrl.login.url;

    return dioRequest<LoginResponse>(
      url: url,
      action: () => _dio.post(url, data: request),
      fromJson: LoginResponse.fromJson,
    );
  }

  Future<void> signup(SignupRequest request) async {
    final url = ApiUrl.signup.url;

    await dioRequest<void>(
      url: url,
      action: () => _dio.post(url, data: request),
    );
  }

  Future<void> logout() async {
    final url = ApiUrl.logout.url;

    await dioRequest<void>(
      url: url,
      action: () => _dio.post(url, options: Options(extra: {'auth': true})),
    );

    await _secureStorageDataSource.deleteToken();
  }

  Future<String> getKakaoLoginUrl() async {
    final url = ApiUrl.kakaoLoginUrl.url;
    String platform = "web";
    if (defaultTargetPlatform == TargetPlatform.android) {
      platform = "android";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = "ios";
    } else {
      platform = "web";
    }

    return await dioRequest(
      url: url,
      action:
          () => _dio.get(
            url,
            queryParameters: {
              if (kDebugMode && platform == "web") 'isDev': true,
              'platform': platform,
            },
          ),
      fromJson: (json) => json['url'],
    );
  }

  Future<String?> getAccessToken() async {
    try {
      String? token = await _secureStorageDataSource.readToken();

      return token;
    } catch (e) {
      debugPrint('토큰 읽기 실패: $e');
      throw Exception('토큰을 읽는 중 오류가 발생했습니다.');
    }
  }
}
