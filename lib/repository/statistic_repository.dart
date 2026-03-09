import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/api_url.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/model/word_statistic.dart';
import 'package:mobidic_flutter/repository/repository.dart';

final statisticRepositoryProvider = Provider<StatisticRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StatisticRepository(dio);
});

class StatisticRepository extends Repository {
  final Dio _dio;

  StatisticRepository(this._dio);

  Future<WordStatistic> getWordStatistic(String wordId) async {
    final url = ApiUrl.wordStatistic.withId(wordId);

    return await dioRequest(
      url: url,
      action:
          () => _dio.get(
            url,
            options: Options(extra: {'auth': true}),
            queryParameters: {'wordId': wordId},
          ),
      fromJson: WordStatistic.fromJson,
    );
  }

  Future<double> getAccuracyOfAll() async {
    final url = ApiUrl.totalAccuracy.url;

    return await dioRequest(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
    );
  }

  Future<void> toggleWordLearned(String wordId) async {
    final url = ApiUrl.toggleLearned.withId(wordId);

    await dioRequest(
      url: url,
      action: () => _dio.patch(url, options: Options(extra: {'auth': true})),
    );
  }

  Future<double> getVocabAccuracy(String vocabId) async {
    final url = ApiUrl.vocabAccuracy.withId(vocabId);

    return await dioRequest(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
    );
  }

  Future<double> getVocabLearningRate(String vocabId) async {
    final url = ApiUrl.vocabLearningRate.withId(vocabId);

    return dioRequest(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
    );
  }
}
