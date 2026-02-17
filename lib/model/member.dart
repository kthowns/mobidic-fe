class Member {
  final String id;
  final String email;
  final String nickname;
  final DateTime? createdAt;

  Member({
    required this.id,
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  factory Member.fromDto(MemberDto dto) => Member(
    id: dto.id,
    email: dto.email,
    nickname: dto.nickname,
    createdAt: dto.createdAt,
  );
}

class MemberDto {
  final String id;
  final String email;
  final String nickname;
  final DateTime? createdAt;

  MemberDto({
    required this.id,
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  factory MemberDto.fromJson(Map<String, dynamic> json) => MemberDto(
    id: json['id'],
    email: json['email'],
    nickname: json['nickname'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
