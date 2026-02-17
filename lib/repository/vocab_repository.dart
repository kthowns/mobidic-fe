import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';

import '../dto/add_vocab_dto.dart';

class VocabRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  VocabRepository(this._apiClient, this._authRepository);

  Future<List<Vocab>> getVocabs() async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/vocab/all',
      headers: {'Authorization': 'Bearer $token'},
      params: {'uId': memberId},
    );
    
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(body.data);
    List<VocabDto> responses = data.map((v) => VocabDto.fromJson(v)).toList();
    List<Vocab> vocabs = [];

    for (VocabDto dto in responses) {
      GeneralResponseDto rateBody = await _apiClient.get(
        url: '/rate/v',
        headers: {'Authorization': 'Bearer $token'},
        params: {'vId': dto.id},
      );

      GeneralResponseDto accuracyBody = await _apiClient.get(
        url: '/rate/accuracy',
        headers: {'Authorization': 'Bearer $token'},
        params: {'vId': dto.id},
      );

      vocabs.add(Vocab.fromDto(dto, rateBody.data, accuracyBody.data));
    }

    return vocabs;
  }

  Future<void> addVocab(String title, String description) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.post(
        url: '/vocab/$memberId',
        headers: {'Authorization': 'Bearer $token'},
        body: AddVocabRequestDto(
            title: title,
            description: description
        ));
  }

  Future<void> updateVocab(String vocabId, String title,
      String description) async {
    String? token = await _authRepository.getToken();

    GeneralResponseDto body = await _apiClient.patch(
        url: '/vocab/$vocabId',
        headers: {'Authorization': 'Bearer $token'},
        body: AddVocabRequestDto(
            title: title,
            description: description
        ));
  }

  Future<void> deleteVocab(String vocabId) async {
    String? token = await _authRepository.getToken();

    GeneralResponseDto body = await _apiClient.delete(
        url: '/vocab/$vocabId',
        headers: {'Authorization': 'Bearer $token'}
    );
  }
}
