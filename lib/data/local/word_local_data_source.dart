import 'package:mobidic/data/local/db_helper.dart';
import 'package:mobidic/data/word_data_source.dart';
import 'package:mobidic/dto/def_dto.dart';
import 'package:mobidic/dto/word_dto.dart';
import 'package:mobidic/model/definition.dart';
import 'package:mobidic/model/word.dart';
import 'package:uuid/uuid.dart';

/// 로컬 DB(SQLite)로부터 단어 데이터를 가져오는 구현체입니다.
class WordLocalDataSource implements WordDataSource {
  final DbHelper _dbHelper = DbHelper();
  final _uuid = const Uuid();

  @override
  Future<List<Word>> getWords(String vocabId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> wordMaps = await db.query(
      'words',
      where: 'vocab_id = ?',
      whereArgs: [vocabId],
      orderBy: 'created_at DESC',
    );

    List<Word> words = [];
    for (var wordMap in wordMaps) {
      final String wordId = wordMap['id'];
      final List<Map<String, dynamic>> defMaps = await db.query(
        'definitions',
        where: 'word_id = ?',
        whereArgs: [wordId],
      );

      final List<Definition> definitions =
          defMaps.map((d) => Definition.fromJsonLocal(d)).toList();

      words.add(
        Word(
          id: wordId,
          expression: wordMap['expression'],
          difficulty: wordMap['difficulty'] ?? 0.0,
          accuracy: wordMap['accuracy'] ?? 0.0,
          isLearned: (wordMap['is_learned'] ?? 0) == 1,
          createdAt:
              wordMap['created_at'] != null
                  ? DateTime.parse(wordMap['created_at'])
                  : null,
          definitions: definitions,
        ),
      );
    }
    return words;
  }

  @override
  Future<void> addWord(
    String vocabId,
    String expression,
    List<AddDefRequestDto> definitions,
  ) async {
    final db = await _dbHelper.database;
    final String wordId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.insert('words', {
        'id': wordId,
        'vocab_id': vocabId,
        'expression': expression,
        'difficulty': 0.0,
        'accuracy': 0.0,
        'is_learned': 0,
        'created_at': now,
      });

      for (var def in definitions) {
        await txn.insert('definitions', {
          'word_id': wordId,
          'part_of_speech': def.part.name,
          'meaning': def.meaning,
        });
      }

      // 단어장 테이블의 단어 수 증가
      await txn.execute(
        'UPDATE vocabularies SET word_count = word_count + 1 WHERE id = ?',
        [vocabId],
      );
    });
  }

  @override
  Future<void> updateWord(
    String wordId,
    AddWordRequestDto word,
    List<Definition> defs,
  ) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'words',
        {'expression': word.expression},
        where: 'id = ?',
        whereArgs: [wordId],
      );

      for (var def in defs) {
        if (def.id.isEmpty) {
          await txn.insert('definitions', {
            'word_id': wordId,
            'part_of_speech': def.part.name,
            'meaning': def.meaning,
          });
        } else {
          await txn.update(
            'definitions',
            {'part_of_speech': def.part.name, 'meaning': def.meaning},
            where: 'id = ?',
            whereArgs: [int.parse(def.id)],
          );
        }
      }
    });
  }

  @override
  Future<void> deleteWord(String wordId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 삭제 전 해당 단어의 vocab_id 조회
      final List<Map<String, dynamic>> maps = await txn.query(
        'words',
        columns: ['vocab_id'],
        where: 'id = ?',
        whereArgs: [wordId],
      );

      if (maps.isNotEmpty) {
        final String vocabId = maps.first['vocab_id'];

        // 단어 삭제 (ON DELETE CASCADE로 인해 뜻도 자동 삭제됨)
        await txn.delete('words', where: 'id = ?', whereArgs: [wordId]);

        // 단어장 테이블의 단어 수 감소
        await txn.execute(
          'UPDATE vocabularies SET word_count = MAX(0, word_count - 1) WHERE id = ?',
          [vocabId],
        );
      }
    });
  }

  @override
  Future<void> deleteDef(String defId) async {
    final db = await _dbHelper.database;
    await db.delete('definitions', where: 'id = ?', whereArgs: [int.parse(defId)]);
  }
}
