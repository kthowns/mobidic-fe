enum PartOfSpeech {
  NOUN('명사'),
  PRONOUN('대명사'),
  VERB('동사'),
  ADJECTIVE('형용사'),
  ADVERB('부사'),
  ARTICLE('관사'),
  PREPOSITION('전치사'),
  CONJUNCTION('접속사'),
  INTERJECTION('감탄사');

  final String label;
  const PartOfSpeech(this.label);
}
