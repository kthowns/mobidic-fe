import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/add_def_dto.dart';
import 'package:mobidic_flutter/dto/add_word_dto.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/rate.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';

import '../model/word.dart';

class WordRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  WordRepository(this._apiClient, this._authRepository);

  Future<List<Word>> getWords(String? vocabId) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.get(
      url: '/word/all',
      headers: {'Authorization': 'Bearer $token'},
      params: {'vId': vocabId},
    );

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      body.data,
    );

    List<WordDto> responses = data.map((v) => WordDto.fromJson(v)).toList();
    List<Word> words = [];

    for (WordDto dto in responses) {
      GeneralResponseDto rateBody = await _apiClient.get(
        url: '/rate/w',
        headers: {'Authorization': 'Bearer $token'},
        params: {'wId': dto.id},
      );

      RateDto rateResponse = RateDto.fromJson(rateBody.data);

      GeneralResponseDto defsBody = await _apiClient.get(
        url: '/def/all',
        headers: {'Authorization': 'Bearer $token'},
        params: {'wId': dto.id},
      );

      List<Map<String, dynamic>> defsData = List<Map<String, dynamic>>.from(
        defsBody.data,
      );
      List<DefDto> defDtos = defsData.map((d) => DefDto.fromJson(d)).toList();
      List<Definition> defs = defDtos.map((d) => Definition.fromDto(d)).toList();

      Word word = Word.fromDto(dto, Rate.fromDto(rateResponse), defs);

      words.add(word);
    }

    return words;
  }

  Future<void> addWord(Vocab? vocab,
      String expression,
      List<DefWithPart> defs,) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto wordsBody = await _apiClient.post(
      url: '/word/${vocab?.id}',
      headers: {'Authorization': 'Bearer $token'},
      body: AddWordRequestDto(expression: expression),
    );

    WordDto wordDto = WordDto.fromJson(wordsBody.data);

    for (DefWithPart def in defs) {
      GeneralResponseDto wordsBody = await _apiClient.post(
        url: '/def/${wordDto.id}',
        headers: {'Authorization': 'Bearer $token'},
        body: AddDefRequestDto(definition: def.definition, part: def.part),
      );
    }
  }

  Future<void> deleteWord(Word word) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.delete(
      url: '/word/${word.id}',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> updateWord(Word word, String exp, List<Definition> defs) async {
    String? token = await _authRepository.getToken();

    GeneralResponseDto body = await _apiClient.patch(
      url: '/word/${word.id}',
      headers: {'Authorization': 'Bearer $token'},
      body: AddWordRequestDto(expression: exp),
    );

    for (Definition def in defs) {
      if(def.id.isEmpty){
        GeneralResponseDto body = await _apiClient.post(
          url: '/def/${word.id}',
          headers: {'Authorization': 'Bearer $token'},
          body: AddDefRequestDto(definition: def.definition, part: def.part),
        );
      } else {
        GeneralResponseDto body = await _apiClient.patch(
          url: '/def/${def.id}',
          headers: {'Authorization': 'Bearer $token'},
          body: AddDefRequestDto(definition: def.definition, part: def.part),
        );
      }
    }
  }

  Future<void> deleteDef(Definition def) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    GeneralResponseDto body = await _apiClient.delete(
      url: '/def/${def.id}',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
