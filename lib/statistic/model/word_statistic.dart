class WordStatistic {
  final String wordId;
  final int correctCount;
  final int incorrectCount;
  final int isLearned;
  final double difficulty;

  WordStatistic({
    required this.wordId,
    required this.correctCount,
    required this.incorrectCount,
    required this.isLearned,
    required this.difficulty,
  });

  factory WordStatistic.fromJson(Map<String, dynamic> json) => WordStatistic(
    wordId: json['wordId'],
    correctCount: json['correctCount'],
    incorrectCount: json['incorrectCount'],
    isLearned: json['isLearned'],
    difficulty: json['difficulty'],
  );
}
