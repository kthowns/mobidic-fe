import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/api/dio.dart';
import 'package:mobidic/dto/def_dto.dart';
import 'package:mobidic/dto/word_dto.dart';
import 'package:mobidic/model/definition.dart';
import 'package:mobidic/repository/repository.dart';

import '../model/word.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dio = ref.read(dioProvider);
  return WordRepository(dio);
});

class WordRepository extends Repository {
  final Dio _dio;

  WordRepository(this._dio);

  Future<List<Word>> getWords(String vocabId) async {
    final url = ApiUrl.getWordsByVocab.withId(vocabId);

    return await dioRequestToList<Word>(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
      fromJson: Word.fromJson,
    );
  }

  Future<void> addWord(
    String vocabId,
    String expression,
    List<AddDefRequestDto> definitions,
  ) async {
    final url = ApiUrl.addWord.withId(vocabId);

    final savedWord = await dioRequest(
      url: url,
      action:
          () => _dio.post(
            url,
            options: Options(extra: {'auth': true}),
            data: AddWordRequestDto(expression: expression),
          ),
      fromJson: AddWordResponseDto.fromJson,
    );

    String wordId = savedWord.id;
    final defUrl = ApiUrl.addDefinition.withId(wordId);

    for (AddDefRequestDto def in definitions) {
      await dioRequest(
        url: defUrl,
        action:
            () => _dio.post(
              defUrl,
              options: Options(extra: {'auth': true}),
              data: def,
            ),
      );
    }
  }

  Future<void> updateWord(
    String wordId,
    AddWordRequestDto word,
    List<Definition> defs,
  ) async {
    final url = ApiUrl.updateWord.withId(wordId);

    await dioRequest(
      url: url,
      action:
          () => _dio.patch(
            url,
            options: Options(extra: {'auth': true}),
            data: word.toJson(),
          ),
    );

    for (Definition def in defs) {
      if (def.id.isEmpty) {
        final addDefUrl = ApiUrl.addDefinition.withId(wordId);

        await dioRequest(
          url: addDefUrl,
          action:
              () => _dio.post(
                addDefUrl,
                options: Options(extra: {'auth': true}),
                data:
                    AddDefRequestDto(
                      meaning: def.meaning,
                      part: def.part,
                    ).toJson(),
              ),
        );
      } else {
        final updateDefUrl = ApiUrl.updateDefinition.withId(def.id);

        await dioRequest(
          url: updateDefUrl,
          action:
              () => _dio.patch(
                updateDefUrl,
                options: Options(extra: {'auth': true}),
                data:
                    AddDefRequestDto(
                      meaning: def.meaning,
                      part: def.part,
                    ).toJson(),
              ),
        );
      }
    }
  }

  Future<void> deleteWord(String wordId) async {
    final url = ApiUrl.deleteWord.withId(wordId);

    await dioRequest(
      url: url,
      action: () => _dio.delete(url, options: Options(extra: {'auth': true})),
    );
  }

  Future<void> deleteDef(String defId) async {
    final url = ApiUrl.deleteDefinition.withId(defId);

    await dioRequest(
      url: url,
      action: () => _dio.delete(url, options: Options(extra: {'auth': true})),
    );
  }
}
