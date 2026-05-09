import 'package:mobidic/model/vocab.dart';

/// 단어장 데이터에 접근하기 위한 추상 인터페이스입니다.
abstract class VocabDataSource {
  Future<List<Vocab>> getVocabs();
  Future<void> addVocab(String title, String description);
  Future<void> updateVocab(String vocabId, String title, String description);
  Future<void> deleteVocab(String vocabId);
}
