import 'package:mobidic_flutter/type/part_of_speech.dart';

class Definition {
  String id;
  String wordId;
  String definition;
  PartOfSpeech part;

  Definition({
    required this.id,
    required this.wordId,
    required this.definition,
    required this.part,
  });

  factory Definition.fromDto(DefDto dto) => Definition(
    id: dto.id,
    wordId: dto.wordId,
    definition: dto.definition,
    part: dto.part,
  );
}

class DefDto {
  final String id;
  final String wordId;
  final String definition;
  final PartOfSpeech part;

  DefDto({
    required this.id,
    required this.wordId,
    required this.definition,
    required this.part,
  });

  static PartOfSpeech parsePart(String value) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw Exception("Invalid part: $value"),
    );
  }

  factory DefDto.fromJson(Map<String, dynamic> json) => DefDto(
    id: json['id'] ?? (throw Exception("id is null")),
    wordId: json['wordId'] ?? (throw Exception("wordId is null")),
    definition: json['definition'] ?? (throw Exception("definition is null")),
    part: parsePart(json['part']),
  );
}

class DefWithPart {
  final String definition;
  final PartOfSpeech part;

  DefWithPart({required this.definition, required this.part});
}
