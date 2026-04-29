import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/api/dio.dart';
import 'package:mobidic/model/user.dart';
import 'package:mobidic/repository/repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.read(dioProvider);
  return UserRepository(dio);
});

class UserRepository extends Repository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<User> getMe() async {
    final url = ApiUrl.me.url;

    return await dioRequest<User>(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
      fromJson: User.fromJson,
    );
  }
}
