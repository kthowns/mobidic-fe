import 'package:mobidic_flutter/type/part_of_speech.dart';

class Definition {
  final String id;
  final String meaning;
  final PartOfSpeech part;

  Definition({required this.id, required this.meaning, required this.part});

  static PartOfSpeech parsePart(String value) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw Exception("Invalid part: $value"),
    );
  }

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
    id: json['id'],
    meaning: json['meaning'],
    part: parsePart(json['part']),
  );
}
