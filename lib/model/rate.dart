import 'package:mobidic_flutter/type/difficulty.dart';

class Rate {
  final String wordId;
  final int correctCount;
  final int incorrectCount;
  final int isLearned;
  final double difficulty;

  Rate({
    required this.wordId,
    required this.correctCount,
    required this.incorrectCount,
    required this.isLearned,
    required this.difficulty,
  });

  factory Rate.fromDto(RateDto dto) => Rate(
    wordId: dto.wordId,
    correctCount: dto.correctCount,
    incorrectCount: dto.incorrectCount,
    isLearned: dto.isLearned,
    difficulty: dto.difficulty,
  );
}

class RateDto {
  final String wordId;
  final int correctCount;
  final int incorrectCount;
  final int isLearned;
  final double difficulty;

  RateDto({
    required this.wordId,
    required this.correctCount,
    required this.incorrectCount,
    required this.isLearned,
    required this.difficulty,
  });

  factory RateDto.fromJson(Map<String, dynamic> json) => RateDto(
    wordId: json['wordId'],
    correctCount: json['correctCount'],
    incorrectCount: json['incorrectCount'],
    isLearned: json['isLearned'],
    difficulty: json['difficulty'],
  );
}
