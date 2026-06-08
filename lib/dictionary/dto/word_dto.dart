import 'package:mobidic/dictionary/dto/def_dto.dart';
import 'package:mobidic/dictionary/model/part_of_speech.dart';

class AddWordRequestDto {
  final String expression;
  final List<AddDefRequestDto> definitions;

  AddWordRequestDto({required this.expression, required this.definitions});

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'definitions': definitions.map((e) => e.toJson()).toList(),
  };
}

class UpdateDefinitionRequestDto {
  final String id;
  final String meaning;
  final PartOfSpeech part;

  UpdateDefinitionRequestDto({
    required this.id,
    required this.meaning,
    required this.part,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'meaning': meaning,
    'part': part.name,
  };
}

class UpdateWordAndDefinitionsRequestDto {
  final String expression;
  final List<UpdateDefinitionRequestDto> updatingDefinitions;
  final List<AddDefRequestDto> addingDefinitions;
  final List<String> deletingDefinitions;

  UpdateWordAndDefinitionsRequestDto({
    required this.expression,
    required this.updatingDefinitions,
    required this.addingDefinitions,
    required this.deletingDefinitions,
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'updatingDefinitions': updatingDefinitions.map((e) => e.toJson()).toList(),
    'addingDefinitions': addingDefinitions.map((e) => e.toJson()).toList(),
    'deletingDefinitions': deletingDefinitions,
  };
}

class AddWordResponseDto {
  final String id;
  final String expression;

  AddWordResponseDto({required this.id, required this.expression});

  factory AddWordResponseDto.fromJson(Map<String, dynamic> json) {
    return AddWordResponseDto(
      id: json['id'] ?? '',
      expression: json['expression'] ?? '',
    );
  }
}
