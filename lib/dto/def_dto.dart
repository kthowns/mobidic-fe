import 'package:mobidic/type/part_of_speech.dart';

class AddDefRequestDto {
  final String meaning;
  final PartOfSpeech part;

  AddDefRequestDto({required this.meaning, required this.part});

  Map<String, dynamic> toJson() => {'meaning': meaning, 'part': part.name};
}
