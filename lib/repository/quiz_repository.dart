import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/api_url.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/dto/quiz_rate_dto.dart';
import 'package:mobidic_flutter/model/quiz.dart';
import 'package:mobidic_flutter/repository/repository.dart';
import 'package:mobidic_flutter/type/quiz_type.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return QuizRepository(dio);
});

class QuizRepository extends Repository {
  final Dio _dio;

  QuizRepository(this._dio);

  Future<List<Quiz>> getQuizzes(String vocabId, QuizType type) async {
    final url = '${ApiUrl.getQuizzes.withId(vocabId)}/${type.name}';

    return await dioRequestToList(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
      fromJson: Quiz.fromJson,
    );
  }

  Future<QuizRateResponseDto> rateQuestion(
    String quizToken,
    String answer,
  ) async {
    final url = ApiUrl.rateQuiz.url;

    return await dioRequest(
      url: url,
      action:
          () => _dio.post(
            url,
            options: Options(extra: {'auth': true}),
            data: QuizRateRequestDto(token: quizToken, answer: answer),
          ),
      fromJson: QuizRateResponseDto.fromJson,
    );
  }
}
