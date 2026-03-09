class Quiz {
  final String token;
  final String stem;
  final List<String> options;
  final int expMil;
  final bool isSolved;

  Quiz({
    required this.token,
    required this.stem,
    required this.options,
    required this.expMil,
    this.isSolved = false,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    token: json['token'],
    stem: json['stem'],
    options: List<String>.from(json['options']),
    expMil: json['expMil'],
  );

  Quiz copyWith({
    String? token,
    String? stem,
    List<String>? options,
    int? expMil,
    bool? isSolved,
  }) => Quiz(
    token: token ?? this.token,
    stem: stem ?? this.stem,
    options: options ?? this.options,
    expMil: expMil ?? this.expMil,
    isSolved: isSolved ?? this.isSolved,
  );
}
