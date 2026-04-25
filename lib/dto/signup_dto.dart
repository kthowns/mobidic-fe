class SignupRequest {
  final String email;
  final String nickname;
  final String password;
  final List<int> agreeTermIds;

  SignupRequest({
    required this.email,
    required this.nickname,
    required this.password,
    required this.agreeTermIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'password': password,
      'agreeTermIds': agreeTermIds,
    };
  }
}
