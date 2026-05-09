import 'package:dio/dio.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/data/vocab_data_source.dart';
import 'package:mobidic/dto/vocab_dto.dart';
import 'package:mobidic/exception/api_exception.dart';
import 'package:mobidic/model/vocab.dart';

/// API(서버)로부터 단어장 데이터를 가져오는 구현체입니다.
class VocabRemoteDataSource implements VocabDataSource {
  final Dio _dio;

  VocabRemoteDataSource(this._dio);

  @override
  Future<List<Vocab>> getVocabs() async {
    final url = ApiUrl.vocabularies.url;
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
      );

      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => Vocab.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleApiException(e);
    } catch (e) {
      throw ApiException(
        message: '알 수 없는 오류가 발생했습니다.',
        status: 500,
        errors: {},
      );
    }
  }

  @override
  Future<void> addVocab(String title, String description) async {
    final url = ApiUrl.addVocabulary.url;
    try {
      await _dio.post(
        url,
        options: Options(extra: {'auth': true}),
        data: AddVocabRequestDto(title: title, description: description),
      );
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    final url = ApiUrl.updateVocabulary.withId(vocabId);
    try {
      await _dio.patch(
        url,
        options: Options(extra: {'auth': true}),
        data: AddVocabRequestDto(title: title, description: description),
      );
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> deleteVocab(String vocabId) async {
    final url = ApiUrl.deleteVocabulary.withId(vocabId);
    try {
      await _dio.delete(url, options: Options(extra: {'auth': true}));
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
