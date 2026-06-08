enum TermType {
  SERVICE("서비스 이용약관"),
  PRIVACY("개인정보 처리방침"),
  MARKETING("마케팅 정보 수신 동의");

  final String label;
  const TermType(this.label);

  static TermType fromString(String value) {
    return TermType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TermType.SERVICE,
    );
  }
}
