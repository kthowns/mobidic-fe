import 'package:mobidic/dto/def_dto.dart';
import 'package:mobidic/dto/word_dto.dart';
import 'package:mobidic/model/definition.dart';
import 'package:mobidic/model/word.dart';

/// 단어 데이터에 접근하기 위한 추상 인터페이스입니다.
abstract class WordDataSource {
  Future<List<Word>> getWords(String vocabId);
  Future<void> addWord(
    String vocabId,
    String expression,
    List<AddDefRequestDto> definitions,
  );
  Future<void> updateWord(
    String wordId,
    AddWordRequestDto word,
    List<Definition> defs,
  );
  Future<void> deleteWord(String wordId);
  Future<void> deleteDef(String defId);
}
