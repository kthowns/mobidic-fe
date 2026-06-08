class Vocab {
  final String id;
  final String title;
  final String description;
  final double learningRate;
  final double accuracy;
  final int wordCount;
  final DateTime? createdAt;

  Vocab({
    required this.id,
    required this.title,
    required this.description,
    required this.learningRate,
    required this.accuracy,
    required this.wordCount,
    required this.createdAt,
  });

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
      id: json['vocabulary']['id'],
      title: json['vocabulary']['title'],
      description: json['vocabulary']['description'],
      learningRate: json['learningRate'],
      accuracy: json['accuracy'],
      wordCount: json['vocabulary']['wordCount'],
      createdAt:
          json['vocabulary']['createdAt'] != null
              ? DateTime.parse(json['vocabulary']['createdAt'])
              : null,
    );
  }
}
