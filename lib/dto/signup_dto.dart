class SignupRequest {
  final String email;
  final String nickname;
  final String password;

  SignupRequest({
    required this.email,
    required this.nickname,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'password': password,
    };
  }
}
