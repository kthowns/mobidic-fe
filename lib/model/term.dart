import 'package:mobidic_flutter/type/term_type.dart';

class Term {
  final int id;
  final TermType type;
  final String version;
  final bool required;
  final String contentUri;
  final DateTime createdAt;

  Term({
    required this.id,
    required this.type,
    required this.version,
    required this.required,
    required this.contentUri,
    required this.createdAt,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'],
      type: TermType.fromString(json['type']),
      version: json['version'],
      required: json['required'],
      contentUri: json['contentUri'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
