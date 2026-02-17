import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/model/rate.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';

class RateRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  RateRepository(this._apiClient, this._authRepository);

  Future<Rate> getRateByWordId(String wordId) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/rate/w',
      headers: {'Authorization': 'Bearer $token'},
      params: {'wId': wordId},
    );

    RateDto rateDto = RateDto.fromJson(body.data);

    return Rate.fromDto(rateDto);
  }

  Future<double> getAccuracyOfAll() async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/rate/accuracy/all',
      headers: {'Authorization': 'Bearer $token'},
      params: {'uId': memberId},
    );

    return body.data;
  }

  Future<void> toggleWordLearned(Word word) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.patch(
      url: '/rate/tog/${word.id}',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<double> getAccuracy(String? vocabId) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/rate/accuracy',
      headers: {'Authorization': 'Bearer $token'},
      params: {'vId': vocabId},
    );

    return body.data;
  }

  Future<double> getLearningRate(String? vocabId) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/rate/v',
      headers: {'Authorization': 'Bearer $token'},
      params: {'vId': vocabId},
    );

    return body.data;
  }
}
