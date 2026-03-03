class AddWordRequestDto {
  final String expression;

  AddWordRequestDto({required this.expression});

  Map<String, dynamic> toJson() => {'expression': expression};
}
