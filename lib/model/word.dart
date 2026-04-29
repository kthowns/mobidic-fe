import 'package:mobidic/model/definition.dart';

class Word {
  String id;
  String expression;
  double difficulty;
  double accuracy;
  bool isLearned = false;
  List<Definition> definitions = [];
  DateTime? createdAt;

  Word({
    required this.id,
    required this.expression,
    required this.difficulty,
    required this.definitions,
    required this.isLearned,
    required this.createdAt,
    required this.accuracy,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    id: json['id'],
    expression: json['expression'],
    difficulty: json['difficulty'],
    accuracy: json['accuracy'],
    isLearned: json['isLearned'],
    definitions:
        (json['definitions'] as List<dynamic>)
            .map((defJson) => Definition.fromJson(defJson))
            .toList(),
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
