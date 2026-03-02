import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/model/word_statistic.dart';
import 'package:mobidic_flutter/model/word.dart';

final statisticRepositoryProvider = Provider<StatisticRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StatisticRepository(dio);
});

class StatisticRepository {
  final Dio _dio;

  StatisticRepository(this._dio);

  Future<WordStatistic> getRateByWordId(String wordId) async {
    final response = await _dio.get(
      '/statistic/word',
      options: Options(extra: {'auth': true}),
      queryParameters: {'wordId': wordId},
    );

    return WordStatistic.fromJson(response.data['data']);
  }

  Future<double> getAccuracyOfAll() async {
    final response = await _dio.get(
      '/statistics/accuracy/all',
      options: Options(extra: {'auth': true}),
    );

    return response.data['data'];
  }

  Future<void> toggleWordLearned(Word word) async {
    await _dio.patch(
      '/statistics/word/${word.id}/learned',
      options: Options(extra: {'auth': true}),
    );
  }

  Future<double> getAccuracy(String vocabId) async {
    final response = await _dio.get(
      '/statistics/vocabulary/$vocabId/accuracy',
      options: Options(extra: {'auth': true}),
    );

    return response.data['data'];
  }

  Future<double> getLearningRate(String vocabId) async {
    final response = await _dio.get(
      '/statistics/vocabulary/$vocabId/learning-rate',
      options: Options(extra: {'auth': true}),
    );

    return response.data['data'];
  }
}
