class Vocab {
  final String id;
  final String memberId;
  final String title;
  final String description;
  final double learningRate;
  final double accuracy;
  final DateTime? createdAt;

  Vocab({
    required this.id,
    required this.memberId,
    required this.title,
    required this.description,
    required this.learningRate,
    required this.accuracy,
    required this.createdAt,
  });

  factory Vocab.fromDto(VocabDto dto, double learningRate, double accuracy) => Vocab(
    id: dto.id,
    memberId: dto.memberId,
    title: dto.title,
    description: dto.description,
    learningRate: learningRate,
    accuracy: accuracy,
    createdAt: dto.createdAt,
  );
}

class VocabDto {
  final String id;
  final String memberId;
  final String title;
  final String description;
  final DateTime? createdAt;

  VocabDto({
    required this.id,
    required this.memberId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory VocabDto.fromJson(Map<String, dynamic> json) => VocabDto(
    id: json['id'],
    memberId: json['memberId'],
    title: json['title'],
    description: json['description'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
