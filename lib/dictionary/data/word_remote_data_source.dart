import 'package:dio/dio.dart';
import 'package:mobidic/global/api/api_url.dart';
import 'package:mobidic/dictionary/data/word_data_source.dart';
import 'package:mobidic/dictionary/dto/def_dto.dart';
import 'package:mobidic/dictionary/dto/word_dto.dart';
import 'package:mobidic/global/exception/api_exception.dart';
import 'package:mobidic/dictionary/model/word.dart';

/// API(서버)로부터 단어 데이터를 가져오는 구현체입니다.
class WordRemoteDataSource implements WordDataSource {
  final Dio _dio;

  WordRemoteDataSource(this._dio);

  @override
  Future<List<Word>> getWords(String vocabId) async {
    final url = ApiUrl.getWordsByVocab.withId(vocabId);
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'auth': true}),
      );
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => Word.fromJson(json)).toList();
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
  Future<void> addWord(
    String vocabId,
    String expression,
    List<AddDefRequestDto> definitions,
  ) async {
    final url = ApiUrl.addWord.withId(vocabId);
    try {
      await _dio.post(
        url,
        options: Options(extra: {'auth': true}),
        data:
            AddWordRequestDto(
              expression: expression,
              definitions: definitions,
            ).toJson(),
      );
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> updateWord(
    String wordId,
    UpdateWordAndDefinitionsRequestDto word,
  ) async {
    final url = ApiUrl.updateWord.withId(wordId);
    try {
      await _dio.patch(
        url,
        options: Options(extra: {'auth': true}),
        data: word.toJson(),
      );
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> deleteWord(String wordId) async {
    final url = ApiUrl.deleteWord.withId(wordId);
    try {
      await _dio.delete(url, options: Options(extra: {'auth': true}));
    } on DioException catch (e) {
      throw _handleApiException(e);
    }
  }

  @override
  Future<void> deleteDef(String defId) async {
    final url = ApiUrl.deleteDefinition.withId(defId);
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
