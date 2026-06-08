class AddVocabRequestDto {
  final String title;
  final String description;

  AddVocabRequestDto({required this.title, required this.description});

  Map<String, dynamic> toJson() => {'title': title, 'description': description};
}
