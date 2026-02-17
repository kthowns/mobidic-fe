class QuestionRateRequestDto {
  final String token;
  final String answer;

  QuestionRateRequestDto({required this.token, required this.answer});

  Map<String, dynamic> toJson() => {'token': token, 'answer': answer};
}

class QuestionRateResponseDto {
  final bool isCorrect;
  final String correctAnswer;

  QuestionRateResponseDto({
    required this.isCorrect,
    required this.correctAnswer,
  });

  factory QuestionRateResponseDto.fromJson(Map<String, dynamic> json) =>
      QuestionRateResponseDto(
        isCorrect: json['isCorrect'],
        correctAnswer: json['correctAnswer'],
      );
}
