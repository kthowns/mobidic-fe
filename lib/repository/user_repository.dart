import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/model/user.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/repository/repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return UserRepository(dio, authRepository);
});

class UserRepository extends Repository {
  final Dio dio;
  final AuthRepository authRepository;

  UserRepository(this.dio, this.authRepository);

  Future<User> getMe() async {
    try {
      final response = await dio.get(
        '/user/me',
        options: Options(extra: {'auth': true}),
      );
      print('/user/me ${response.data}');
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('/user/me error : ${e.response?.data} $e');
      throw handleApiException(e);
    } catch (e) {
      print('/user/me unknown error: $e');
      throw handleUnknownException(e);
    }
  }
}
