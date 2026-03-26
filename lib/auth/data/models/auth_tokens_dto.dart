class AuthTokensDto {
  final String accessToken;
  final String refreshToken;

  const AuthTokensDto({required this.accessToken, required this.refreshToken});

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
