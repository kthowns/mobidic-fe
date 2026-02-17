import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/model/member.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';

class MemberRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  MemberRepository(this._apiClient, this._authRepository);

  Future<Member> getMemberDetail(String memberId) async {
    String? token = await _authRepository.getToken();

    GeneralResponseDto body = await _apiClient.get(
      url: '/user/detail',
      headers: {'Authorization': 'Bearer $token'},
      params: {'uId': memberId},
    );

    MemberDto response = MemberDto.fromJson(body.data);

    return Member.fromDto(response);
  }
}
