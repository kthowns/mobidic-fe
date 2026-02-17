class JoinRequestDto {
  final String email;
  final String nickname;
  final String password;

  JoinRequestDto({
    required this.email,
    required this.nickname,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'nickname': nickname,
    'password': password,
  };
}