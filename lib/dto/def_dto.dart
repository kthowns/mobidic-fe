import 'package:mobidic_flutter/type/part_of_speech.dart';

class AddDefRequestDto {
  final String definition;
  final PartOfSpeech part;

  AddDefRequestDto({
    required this.definition,
    required this.part,
  });

  Map<String, dynamic> toJson() => {
    'definition': definition,
    'part': part.name
  };
}
