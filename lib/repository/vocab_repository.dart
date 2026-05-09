import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/api/dio.dart';
import 'package:mobidic/data/local/vocab_local_data_source.dart';
import 'package:mobidic/data/remote/vocab_remote_data_source.dart';
import 'package:mobidic/data/vocab_data_source.dart';
import 'package:mobidic/model/vocab.dart';
import 'package:mobidic/repository/repository.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';

final vocabDataSourceProvider = Provider<VocabDataSource>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final isLoggedIn = authState.currentUser != null;

  if (isLoggedIn) {
    final dio = ref.read(dioProvider);
    return VocabRemoteDataSource(dio);
  } else {
    return VocabLocalDataSource();
  }
});

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final dataSource = ref.watch(vocabDataSourceProvider);
  return VocabRepository(dataSource);
});

class VocabRepository extends Repository {
  final VocabDataSource _dataSource;

  VocabRepository(this._dataSource);

  Future<List<Vocab>> getVocabs() async {
    return await _dataSource.getVocabs();
  }

  Future<void> addVocab(String title, String description) async {
    await _dataSource.addVocab(title, description);
  }

  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    await _dataSource.updateVocab(vocabId, title, description);
  }

  Future<void> deleteVocab(String vocabId) async {
    await _dataSource.deleteVocab(vocabId);
  }
}
