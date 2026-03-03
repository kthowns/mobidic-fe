import 'package:mobidic_flutter/type/part_of_speech.dart';

class Definition {
  final String id;
  final String definition;
  final PartOfSpeech part;

  Definition({required this.id, required this.definition, required this.part});

  static PartOfSpeech parsePart(String value) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw Exception("Invalid part: $value"),
    );
  }

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
    id: json['id'],
    definition: json['definition'],
    part: parsePart(json['part']),
  );
}
