/// 영구 저장소(Storage)에서 사용하는 키 상수 Enum
enum StorageKey {
  jwtToken('jwt_token');

  final String key;
  const StorageKey(this.key);
}
