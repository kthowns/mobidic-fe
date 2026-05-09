import 'package:mobidic/model/word_statistic.dart';

/// 통계 데이터에 접근하기 위한 추상 인터페이스입니다.
abstract class StatisticDataSource {
  Future<WordStatistic> getWordStatistic(String wordId);
  Future<double> getAccuracyOfAll();
  Future<void> toggleWordLearned(String wordId);
  Future<double> getVocabAccuracy(String vocabId);
  Future<double> getVocabLearningRate(String vocabId);
}
