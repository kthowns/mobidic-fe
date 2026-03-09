class QuizRateRequestDto {
  final String token;
  final String answer;

  QuizRateRequestDto({required this.token, required this.answer});

  Map<String, dynamic> toJson() => {'token': token, 'answer': answer};
}

class QuizRateResponseDto {
  final bool isCorrect;
  final String correctAnswer;

  QuizRateResponseDto({required this.isCorrect, required this.correctAnswer});

  factory QuizRateResponseDto.fromJson(Map<String, dynamic> json) =>
      QuizRateResponseDto(
        isCorrect: json['isCorrect'],
        correctAnswer: json['correctAnswer'],
      );
}
