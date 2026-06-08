import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/global/api/dio.dart';
import 'package:mobidic/statistic/data/statistic_local_data_source.dart';
import 'package:mobidic/statistic/data/statistic_remote_data_source.dart';
import 'package:mobidic/statistic/data/statistic_data_source.dart';
import 'package:mobidic/statistic/model/word_statistic.dart';
import 'package:mobidic/global/repository/base_repository.dart';
import 'package:mobidic/auth/viewmodel/auth_view_model.dart';

final statisticDataSourceProvider = Provider<StatisticDataSource>((ref) {
  final authState = ref.watch(authViewModelProvider);

  if (authState.isLoggedIn) {
    final dio = ref.read(dioProvider);
    return StatisticRemoteDataSource(dio);
  } else {
    return StatisticLocalDataSource();
  }
});

final statisticRepositoryProvider = Provider<StatisticRepository>((ref) {
  final dataSource = ref.watch(statisticDataSourceProvider);
  return StatisticRepository(dataSource);
});

class StatisticRepository extends Repository {
  final StatisticDataSource _dataSource;

  StatisticRepository(this._dataSource);

  Future<WordStatistic> getWordStatistic(String wordId) async {
    return await _dataSource.getWordStatistic(wordId);
  }

  Future<double> getAccuracyOfAll() async {
    return await _dataSource.getAccuracyOfAll();
  }

  Future<void> toggleWordLearned(String wordId) async {
    await _dataSource.toggleWordLearned(wordId);
  }

  Future<double> getVocabAccuracy(String vocabId) async {
    return await _dataSource.getVocabAccuracy(vocabId);
  }

  Future<double> getVocabLearningRate(String vocabId) async {
    return await _dataSource.getVocabLearningRate(vocabId);
  }
}
