import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/data/secure_storage_data_source.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/dto/join_dto.dart';
import 'package:mobidic_flutter/dto/login_dto.dart';
import 'package:mobidic_flutter/model/member.dart';

class AuthRepository {
  final SecureStorageDataSource _secureStorageDataSource;
  final ApiClient _apiClient;

  AuthRepository(this._secureStorageDataSource, this._apiClient);

  Future<LoginResponseDto> login(String email, String password) async {
    GeneralResponseDto body = await _apiClient.post(
      url: '/auth/login',
      body: LoginRequestDto(email: email, password: password),
    );

    LoginResponseDto response = LoginResponseDto.fromJson(body.data);

    await _secureStorageDataSource.saveToken(response.token);
    await _secureStorageDataSource.saveMemberId(response.memberId);

    return response;
  }

  Future<Member> join(
    String email,
    String nickname,
      String password,
  ) async {
    GeneralResponseDto body = await _apiClient.post(
      url: '/auth/join',
      body: JoinRequestDto(
        email: email,
        password: password,
        nickname: nickname,
      ),
    );

    MemberDto response = MemberDto.fromJson(body.data);

    return Member.fromDto(response);
  }

  Future<void> logout() async {
    String? token = await _secureStorageDataSource.readToken();

    GeneralResponseDto body = await _apiClient.post(
      url: '/auth/logout',
      headers: {'Authorization': 'Bearer $token'},
    );

    await _secureStorageDataSource.deleteMemberId();
    await _secureStorageDataSource.deleteToken();
  }

  Future<String?> getToken() async {
    String? token = await _secureStorageDataSource.readToken();
    return token;
  }

  Future<String> getCurrentMemberId() async {
    String? memberId = await _secureStorageDataSource.readMemberId();
    if (memberId == null) {
      throw Exception('Not logged in');
    }
    return memberId;
  }
}
