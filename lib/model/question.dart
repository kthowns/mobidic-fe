class Question {
  final String token;
  final String stem;
  final List<String> options;
  final int expMil;

  Question({
    required this.token,
    required this.stem,
    required this.options,
    required this.expMil,
  });

  factory Question.fromDto(QuestionDto dto) => Question(
    token: dto.token,
    stem: dto.stem,
    options: dto.options,
    expMil: dto.expMil,
  );
}

class QuestionDto {
  final String token;
  final String stem;
  final List<String> options;
  final int expMil;

  QuestionDto({
    required this.token,
    required this.stem,
    required this.options,
    required this.expMil,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) => QuestionDto(
    token: json['token'],
    stem: json['stem'],
    options: List<String>.from(json['options']),
    expMil: json['expMil'],
  );
}
