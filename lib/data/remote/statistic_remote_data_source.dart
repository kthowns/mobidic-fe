import 'package:dio/dio.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/data/statistic_data_source.dart';
import 'package:mobidic/exception/api_exception.dart';
import 'package:mobidic/model/word_statistic.dart';

/// API(서버)로부터 통계 데이터를 가져오는 구현체입니다.
class StatisticRemoteDataSource implements StatisticDataSource {
  final Dio _dio;

  StatisticRemoteDataSource(this._dio);

  @override
  Future<WordStatistic> getWordStatistic(String wordId) async {
    final url = ApiUrl.wordStatistic.withId(wordId);
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
        queryParameters: {'wordId': wordId},
      );
      return WordStatistic.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<double> getAccuracyOfAll() async {
    final url = ApiUrl.totalAccuracy.url;
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
      );
      return (response.data['data'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> toggleWordLearned(String wordId) async {
    final url = ApiUrl.toggleLearned.withId(wordId);
    try {
      await _dio.patch(url, options: Options(extra: {'auth': true}));
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<double> getVocabAccuracy(String vocabId) async {
    final url = ApiUrl.vocabAccuracy.withId(vocabId);
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
      );
      return (response.data['data'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<double> getVocabLearningRate(String vocabId) async {
    final url = ApiUrl.vocabLearningRate.withId(vocabId);
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
      );
      return (response.data['data'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  ApiException _handleApiException(DioException e) {
    final data = e.response?.data;
    final Map<String, dynamic> mapData =
        data is Map<String, dynamic> ? data : {};

    return ApiException(
      message: mapData['message'] ?? '알 수 없는 오류가 발생했습니다.',
      status: mapData['status'] ?? 500,
      errors: mapData['errors'] ?? {},
    );
  }
}
