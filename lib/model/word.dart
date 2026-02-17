import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/rate.dart';

class Word {
  String id;
  String vocabId;
  String expression;
  double difficulty;
  bool isLearned = false;
  List<Definition> defs = [];
  DateTime? createdAt;

  Word({
    required this.id,
    required this.vocabId,
    required this.expression,
    required this.difficulty,
    required this.defs,
    required this.isLearned,
    required this.createdAt,
  });

  factory Word.fromDto(
    WordDto wordDto,
    Rate rate,
    List<Definition> defs,
  ) => Word(
    id: wordDto.id,
    vocabId: wordDto.vocabId,
    expression: wordDto.expression,
    difficulty: rate.difficulty,
    defs: defs,
    isLearned: rate.isLearned != 0 ? true : false,
    createdAt: wordDto.createdAt,
  );
}

class WordDto {
  final String id;
  final String vocabId;
  final String expression;
  final DateTime? createdAt;

  WordDto({
    required this.id,
    required this.vocabId,
    required this.expression,
    required this.createdAt,
  });

  factory WordDto.fromJson(Map<String, dynamic> json) => WordDto(
    id: json['id'],
    vocabId: json['vocabId'],
    expression: json['expression'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
