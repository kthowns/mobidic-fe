import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/repository.dart';
import '../dto/vocab_dto.dart';

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VocabRepository(dio);
});

class VocabRepository extends Repository {
  final Dio _dio;

  VocabRepository(this._dio);

  Future<List<Vocab>> getVocabs() async {
    try {
      final response = await _dio.get(
        '/vocabularies/all',
        options: Options(extra: {'auth': true}),
      );

      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response.data['data'] as List,
      );
      List<Vocab> vocabs = data.map((v) => Vocab.fromJson(v)).toList();

      return vocabs;
    } on DioException catch (e) {
      print('/vocabularies/all error: ${e.message} $e');
      throw handleApiException(e);
    } catch (e) {
      print('/vocabularies/all unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> addVocab(String title, String description) async {
    try {
      await _dio.post(
        '/vocabularies',
        options: Options(extra: {'auth': true}),
        data: AddVocabRequestDto(title: title, description: description),
      );
    } on DioException catch (e) {
      print('/vocabularies add error: ${e.message} $e');
      throw handleApiException(e);
    } catch (e) {
      print('/vocabularies add unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    try {
      await _dio.patch(
        '/vocabularies/$vocabId',
        options: Options(extra: {'auth': true}),
        data: AddVocabRequestDto(title: title, description: description),
      );
    } on DioException catch (e) {
      print('/vocabularies/$vocabId error: ${e.message} $e');
      throw handleApiException(e);
    } catch (e) {
      print('/vocabularies/$vocabId unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  Future<void> deleteVocab(String vocabId) async {
    try {
      await _dio.delete(
        '/vocabularies/$vocabId',
        options: Options(extra: {'auth': true}),
      );
    } on DioException catch (e) {
      print('/vocabularies/$vocabId error: ${e.message} $e');
      throw handleApiException(e);
    } catch (e) {
      print('/vocabularies/$vocabId unknown error: $e');
      throw handleUnknownException(e);
    }
  }
}
