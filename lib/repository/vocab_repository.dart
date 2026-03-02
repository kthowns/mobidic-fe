import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import '../dto/add_vocab_dto.dart';

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VocabRepository(dio);
});

class VocabRepository {
  final Dio _dio;

  VocabRepository(this._dio);

  Future<List<Vocab>> getVocabs() async {
    final response = await _dio.get(
      '/vocabularies/all',
      options: Options(extra: {'auth': true}),
    );

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response.data['data'] as List,
    );
    print('getVocabs response: ${response.data}');
    List<Vocab> vocabs = data.map((v) => Vocab.fromJson(v)).toList();

    print('vocabs response: $vocabs');
    return vocabs;
  }

  Future<void> addVocab(String title, String description) async {
    await _dio.post(
      '/vocabularies',
      options: Options(extra: {'auth': true}),
      data: AddVocabRequestDto(title: title, description: description),
    );
  }

  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    await _dio.patch(
      '/vocabularies/$vocabId',
      options: Options(extra: {'auth': true}),
      data: AddVocabRequestDto(title: title, description: description),
    );
  }

  Future<void> deleteVocab(String vocabId) async {
    await _dio.delete(
      '/vocabularies/$vocabId',
      options: Options(extra: {'auth': true}),
    );
  }
}
