class AddWordRequestDto {
  final String expression;

  AddWordRequestDto({required this.expression});

  Map<String, dynamic> toJson() => {'expression': expression};
}

class AddWordResponseDto {
  final String id;
  final String expression;

  AddWordResponseDto({required this.id, required this.expression});

  factory AddWordResponseDto.fromJson(Map<String, dynamic> json) {
    return AddWordResponseDto(
      id: json['id'] ?? '',
      expression: json['expression'] ?? '',
    );
  }
}
