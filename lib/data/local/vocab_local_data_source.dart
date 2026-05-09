import 'package:mobidic/data/local/db_helper.dart';
import 'package:mobidic/data/vocab_data_source.dart';
import 'package:mobidic/model/vocab.dart';
import 'package:uuid/uuid.dart';

/// 로컬 DB(SQLite)로부터 단어장 데이터를 가져오는 구현체입니다.
class VocabLocalDataSource implements VocabDataSource {
  final DbHelper _dbHelper = DbHelper();
  final _uuid = const Uuid();

  @override
  Future<List<Vocab>> getVocabs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabularies',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vocab(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'] ?? '',
        learningRate: maps[i]['learning_rate'] ?? 0.0,
        accuracy: maps[i]['accuracy'] ?? 0.0,
        wordCount: maps[i]['word_count'] ?? 0,
        createdAt:
            maps[i]['created_at'] != null
                ? DateTime.parse(maps[i]['created_at'])
                : null,
      );
    });
  }

  @override
  Future<void> addVocab(String title, String description) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    await db.insert('vocabularies', {
      'id': _uuid.v4(),
      'title': title,
      'description': description,
      'learning_rate': 0.0,
      'accuracy': 0.0,
      'word_count': 0,
      'created_at': now.toIso8601String(),
    });
  }

  @override
  Future<void> updateVocab(
    String vocabId,
    String title,
    String description,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'vocabularies',
      {'title': title, 'description': description},
      where: 'id = ?',
      whereArgs: [vocabId],
    );
  }

  @override
  Future<void> deleteVocab(String vocabId) async {
    final db = await _dbHelper.database;
    await db.delete('vocabularies', where: 'id = ?', whereArgs: [vocabId]);
  }
}
