import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/api/dio.dart';
import 'package:mobidic/dto/quiz_rate_dto.dart';
import 'package:mobidic/model/quiz.dart';
import 'package:mobidic/repository/repository.dart';
import 'package:mobidic/type/quiz_type.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dio = ref.read(dioProvider);

  return QuizRepository(dio);
});

class QuizRepository extends Repository {
  final Dio _dio;

  QuizRepository(this._dio);

  Future<List<Quiz>> getQuizzes(String vocabId, QuizType type) async {
    final url = switch (type) {
      QuizType.OX => ApiUrl.getOxQuizzes.withId(vocabId),
      QuizType.BLANK => ApiUrl.getBlankQuizzes.withId(vocabId),
      QuizType.DICTATION =>
        '${ApiUrl.vocabularies.url}/$vocabId/quizzes/dictation', // Spec might be missing this, keeping a fallback pattern or check
    };

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
