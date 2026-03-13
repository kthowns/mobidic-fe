import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/api_url.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/dto/vocab_dto.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/repository.dart';

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final dio = ref.read(dioProvider);
  return VocabRepository(dio);
});

class VocabRepository extends Repository {
  final Dio _dio;

  VocabRepository(this._dio);

  Future<List<Vocab>> getVocabs() async {
    final url = ApiUrl.vocabularies.url;

    return await dioRequestToList<Vocab>(
      url: url,
      action: () => _dio.get(url, options: Options(extra: {'auth': true})),
      fromJson: Vocab.fromJson,
    );
  }

  Future<void> addVocab(String title, String description) async {
    final url = ApiUrl.addVocabulary.url;

    await dioRequest(
      url: url,
      action:
          () => _dio.post(
            url,
            options: Options(extra: {'auth': true}),
            data: AddVocabRequestDto(title: title, description: description),
          ),
    );
  }

  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    final url = ApiUrl.updateVocabulary.withId(vocabId);

    await dioRequest(
      url: url,
      action:
          () => _dio.patch(
            url,
            options: Options(extra: {'auth': true}),
            data: AddVocabRequestDto(title: title, description: description),
          ),
    );
  }

  Future<void> deleteVocab(String vocabId) async {
    final url = ApiUrl.deleteVocabulary.withId(vocabId);

    await dioRequest(
      url: url,
      action: () => _dio.delete(url, options: Options(extra: {'auth': true})),
    );
  }
}
