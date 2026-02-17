import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/add_word_dto.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/dto/question_rate_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/question.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/type/quiz_type.dart';

import '../model/word.dart';

class QuestionRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  QuestionRepository(this._apiClient, this._authRepository);

  Future<List<Question>> getQuestions(String? vocabId, QuizType type) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/quiz/generate/${type.name}',
      headers: {'Authorization': 'Bearer $token'},
      params: {'vId': vocabId},
    );

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      body.data,
    );

    List<QuestionDto> responses =
        data.map((q) => QuestionDto.fromJson(q)).toList();
    List<Question> questions =
        responses.map((q) => Question.fromDto(q)).toList();

    return questions;
  }

  Future<QuestionRateResponseDto> rateQuestion(String questionToken, String answer) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto responseBody = await _apiClient.post(
      url: '/quiz/rate',
      headers: {'Authorization': 'Bearer $token'},
      body: QuestionRateRequestDto(token: questionToken, answer: answer),
    );

    return QuestionRateResponseDto.fromJson(responseBody.data);
  }
}
