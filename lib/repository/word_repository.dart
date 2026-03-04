import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/dto/def_dto.dart';
import 'package:mobidic_flutter/dto/word_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/repository.dart';

import '../model/word.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WordRepository(dio);
});

class WordRepository extends Repository {
  final Dio _dio;

  WordRepository(this._dio);

  Future<List<Word>> getWords(String vocabId) async {
    try {
      final response = await _dio.get(
        '/words',
        options: Options(extra: {'auth': true}),
        queryParameters: {'vocabularyId': vocabId},
      );

      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response.data['data'] as List,
      );

      return data.map((v) => Word.fromJson(v)).toList();
    } on DioException catch (e) {
      print('/words error: ${e.message}');
      throw handleApiException(e);
    } catch (e) {
      print('/words unknown error: $e');
      throw handleUnknownException(e);
    }
  }

    Future<void> addWord(
      Vocab vocab,
      String expression,
      List<AddDefRequestDto> definitions,
    ) async {
      try {
        final response = await _dio.post(
          '/words/${vocab.id}',
          options: Options(extra: {'auth': true}),
          data: AddWordRequestDto(expression: expression).toJson(),
        );

        String wordId = response.data['data']['id'];

        for (AddDefRequestDto def in definitions) {
          await _dio.post(
            '/definitions/$wordId',
            options: Options(extra: {'auth': true}),
            data: def.toJson(),
          );
        }
      } on DioException catch (e) {
        print('/words add error: ${e.message}');
        throw handleApiException(e);
      } catch (e) {
        print('/words add unknown error: $e');
        throw handleUnknownException(e);
      }
    }

    Future<void> updateWord(
      String wordId,
      AddWordRequestDto word,
      List<Definition> defs,
    ) async {
      try {
        await _dio.patch(
          '/words/$wordId',
          options: Options(extra: {'auth': true}),
          data: word.toJson(),
        );

        for (Definition def in defs) {
          if (def.id.isEmpty) {
            await _dio.post(
              '/definitions/$wordId',
              options: Options(extra: {'auth': true}),
              data:
                  AddDefRequestDto(meaning: def.meaning, part: def.part).toJson(),
            );
          } else {
            await _dio.patch(
              '/definitions/${def.id}',
              options: Options(extra: {'auth': true}),
              data:
                  AddDefRequestDto(meaning: def.meaning, part: def.part).toJson(),
            );
          }
        }
      } on DioException catch (e) {
        print('/words update error: ${e.message}');
        throw handleApiException(e);
      } catch (e) {
        print('/words update unknown error: $e');
        throw handleUnknownException(e);
      }
    }

  Future<void> deleteWord(Word word) async {
    try {
      await _dio.delete(
        '/words/${word.id}',
        options: Options(extra: {'auth': true}),
      );
    } on DioException catch (e) {
      print('/words delete error: ${e.message}');
      throw handleApiException(e);
    } catch (e) {
      print('/words delete unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> deleteDef(Definition def) async {
    try {
      await _dio.delete(
        '/definitions/${def.id}',
        options: Options(extra: {'auth': true}),
      );
    } on DioException catch (e) {
      print('/definitions delete error: ${e.message}');
      throw handleApiException(e);
    } catch (e) {
      print('/definitions delete unknown error: $e');
      throw handleUnknownException(e);
    }
  }
}
