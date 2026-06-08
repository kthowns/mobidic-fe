import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/global/api/dio.dart';
import 'package:mobidic/dictionary/data/word_local_data_source.dart';
import 'package:mobidic/dictionary/data/word_remote_data_source.dart';
import 'package:mobidic/dictionary/data/word_data_source.dart';
import 'package:mobidic/dictionary/dto/def_dto.dart';
import 'package:mobidic/dictionary/dto/word_dto.dart';
import 'package:mobidic/dictionary/model/word.dart';
import 'package:mobidic/global/repository/base_repository.dart';
import 'package:mobidic/auth/viewmodel/auth_view_model.dart';

final wordDataSourceProvider = Provider<WordDataSource>((ref) {
  final authState = ref.watch(authViewModelProvider);

  if (authState.isLoggedIn) {
    final dio = ref.read(dioProvider);
    return WordRemoteDataSource(dio);
  } else {
    return WordLocalDataSource();
  }
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dataSource = ref.watch(wordDataSourceProvider);
  return WordRepository(dataSource);
});

class WordRepository extends Repository {
  final WordDataSource _dataSource;

  WordRepository(this._dataSource);

  Future<List<Word>> getWords(String vocabId) async {
    return await _dataSource.getWords(vocabId);
  }

  Future<void> addWord(
    String vocabId,
    String expression,
    List<AddDefRequestDto> definitions,
  ) async {
    await _dataSource.addWord(vocabId, expression, definitions);
  }

  Future<void> updateWord(
    String wordId,
    UpdateWordAndDefinitionsRequestDto word,
  ) async {
    await _dataSource.updateWord(wordId, word);
  }

  Future<void> deleteWord(String wordId) async {
    await _dataSource.deleteWord(wordId);
  }

  Future<void> deleteDef(String defId) async {
    await _dataSource.deleteDef(defId);
  }
}
