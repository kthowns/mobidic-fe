import 'package:mobidic/data/local/db_helper.dart';
import 'package:mobidic/data/statistic_data_source.dart';
import 'package:mobidic/model/word_statistic.dart';

/// 로컬 DB(SQLite)로부터 통계 데이터를 계산하여 가져오는 구현체입니다.
class StatisticLocalDataSource implements StatisticDataSource {
  final DbHelper _dbHelper = DbHelper();

  @override
  Future<WordStatistic> getWordStatistic(String wordId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      columns: [
        'id',
        'difficulty',
        'is_learned',
        'correct_count',
        'incorrect_count',
      ],
      where: 'id = ?',
      whereArgs: [wordId],
    );

    if (maps.isNotEmpty) {
      return WordStatistic(
        wordId: wordId,
        correctCount: maps[0]['correct_count'] ?? 0,
        incorrectCount: maps[0]['incorrect_count'] ?? 0,
        isLearned: maps[0]['is_learned'] ?? 0,
        difficulty: maps[0]['difficulty'] ?? 0.0,
      );
    }
    return WordStatistic(
      wordId: wordId,
      correctCount: 0,
      incorrectCount: 0,
      isLearned: 0,
      difficulty: 0.0,
    );
  }

  @override
  Future<double> getAccuracyOfAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(accuracy) as avg_accuracy FROM vocabularies',
    );

    if (result.isNotEmpty && result[0]['avg_accuracy'] != null) {
      return (result[0]['avg_accuracy'] as num).toDouble();
    }
    return 0.0;
  }

  @override
  Future<void> toggleWordLearned(String wordId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      columns: ['is_learned'],
      where: 'id = ?',
      whereArgs: [wordId],
    );

    if (maps.isNotEmpty) {
      int currentStatus = maps[0]['is_learned'] ?? 0;
      await db.update(
        'words',
        {'is_learned': currentStatus == 1 ? 0 : 1},
        where: 'id = ?',
        whereArgs: [wordId],
      );
    }
  }

  @override
  Future<double> getVocabAccuracy(String vocabId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'vocabularies',
      columns: ['accuracy'],
      where: 'id = ?',
      whereArgs: [vocabId],
    );

    if (result.isNotEmpty && result[0]['accuracy'] != null) {
      return (result[0]['accuracy'] as num).toDouble();
    }
    return 0.0;
  }

  @override
  Future<double> getVocabLearningRate(String vocabId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'vocabularies',
      columns: ['learning_rate'],
      where: 'id = ?',
      whereArgs: [vocabId],
    );

    if (result.isNotEmpty && result[0]['learning_rate'] != null) {
      return (result[0]['learning_rate'] as num).toDouble();
    }
    return 0.0;
  }
}
