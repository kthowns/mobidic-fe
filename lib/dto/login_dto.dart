class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponseDto {
  final String memberId;
  final String token;

  LoginResponseDto({required this.memberId, required this.token});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      LoginResponseDto(memberId: json['memberId'], token: json['token']);
}
