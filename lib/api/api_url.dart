enum ApiUrl {
  // 인증 관련 서비스
  login("/api/auth/login", null),
  signup("/api/users/signup", null),
  logout("/api/auth/logout", null),
  kakaoLoginUrl("/api/auth/login-url/kakao", null),
  kakaoLogin("/api/auth/v1/oauth2/kakao", null),

  // 사용자 관련 서비스
  me("/api/users/me", null),
  updateMe("/api/users/me", null),
  deactivateUser("/api/users/me", null),

  // 단어장 관련 서비스
  vocabularies("/api/vocabularies", null),
  addVocabulary("/api/vocabularies", null),
  getVocabulary("/api/vocabularies/{vocabularyId}", "vocabularyId"),
  updateVocabulary("/api/vocabularies/{vocabularyId}", "vocabularyId"),
  deleteVocabulary("/api/vocabularies/{vocabularyId}", "vocabularyId"),

  // 단어 관련 서비스
  getWordsByVocab("/api/vocabularies/{vocabularyId}/words", "vocabularyId"),
  addWord("/api/vocabularies/{vocabularyId}/word", "vocabularyId"),
  updateWord("/api/words/{wordId}", "wordId"),
  deleteWord("/api/words/{wordId}", "wordId"),

  // 뜻 관련 서비스
  getDefinitions("/api/words/{wordId}/definitions", "wordId"),
  addDefinition("/api/words/{wordId}/definition", "wordId"),
  updateDefinition("/api/definitions/{definitionId}", "definitionId"),
  deleteDefinition("/api/definitions/{definitionId}", "definitionId"),

  // 퀴즈 관련 서비스
  getQuizzes("/api/vocabularies/{vocabularyId}/quizzes", "vocabularyId"),
  rateQuiz("/api/quizzes/rate", null),

  // 발음 체크 관련 서비스
  pronunciation("/api/words/{wordId}/pronunciation", "wordId"),

  // 통계 관련 서비스
  wordStatistic("/api/words/{wordId}/statistic", "wordId"),
  toggleLearned("/api/words/{wordId}/toggle-learned", "wordId"),
  vocabLearningRate(
    "/api/vocabularies/{vocabularyId}/learning-rate",
    "vocabularyId",
  ),
  vocabAccuracy("/api/vocabularies/{vocabularyId}/accuracy", "vocabularyId"),
  totalAccuracy("/api/users/me/accuracy", null);

  final String url;
  final String? key;
  const ApiUrl(this.url, this.key);

  /// 경로 파라미터가 포함된 URL을 실제 값으로 변환해주는 헬퍼 메서드
  String withId(String id) {
    if (key == null) {
      return url;
    }
    return url.replaceAll("{$key}", id);
  }
}
