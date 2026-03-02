import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/data/secure_storage_data_source.dart';
import 'package:mobidic_flutter/dto/login_dto.dart';
import 'package:mobidic_flutter/dto/signup_dto.dart';
import 'package:mobidic_flutter/repository/repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorageDataSource = ref.watch(secureStorageDataSourceProvider);
  final dio = ref.watch(dioProvider);
  return AuthRepository(secureStorageDataSource, dio);
});

class AuthRepository extends Repository {
  final SecureStorageDataSource _secureStorageDataSource;
  final Dio dio;

  AuthRepository(this._secureStorageDataSource, this.dio);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dio.post('/auth/login', data: request.toJson());
      print('success /auth/login ${response.data}');

      return LoginResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleApiException(e);
    } catch (e) {
      print('/auth/login unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> signup(SignupRequest request) async {
    try {
      final response = await dio.post('/auth/signup', data: request.toJson());
      print('/auth/signup ${response.data}');
    } on DioException catch (e) {
      throw handleApiException(e);
    } catch (e) {
      print('/auth/signup unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> logout() async {
    try {
      final response = await dio.post(
        '/auth/logout',
        options: Options(extra: {'auth': true}),
      );
      print('/auth/logout ${response.data}');
    } on DioException catch (e) {
      throw handleApiException(e);
    } catch (e) {
      print('/auth/logout unknown error: $e');
      throw handleUnknownException(e);
    }

    await _secureStorageDataSource.deleteToken();
  }

  Future<String?> getAccessToken() async {
    try {
      String? token = await _secureStorageDataSource.readToken();

      return token;
    } catch (e) {
      print('토큰 읽기 실패: $e');
      throw Exception('토큰을 읽는 중 오류가 발생했습니다.');
    }
  }
}
