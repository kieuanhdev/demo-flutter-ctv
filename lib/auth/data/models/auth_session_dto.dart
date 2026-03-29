import '../../domain/entities/auth_profile.dart';
import '../../domain/entities/auth_session.dart';
import 'auth_profile_dto.dart';

class AuthSessionDto {
  final AuthProfileDto profile;
  final String accessToken;

  const AuthSessionDto({
    required this.profile,
    required this.accessToken,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    final token = (json['accessToken'] ?? json['token']) as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing access token in auth response');
    }

    return AuthSessionDto(
      profile: AuthProfileDto.fromJson(json),
      accessToken: token,
    );
  }

  AuthSessionDto copyWith({
    AuthProfileDto? profile,
    String? accessToken,
  }) {
    return AuthSessionDto(
      profile: profile ?? this.profile,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  AuthSession toDomain() {
    return AuthSession(
      accessToken: accessToken,
      profile: AuthProfile(
        id: profile.id,
        username: profile.username,
        email: profile.email,
        firstName: profile.firstName,
        lastName: profile.lastName,
        gender: profile.gender,
        image: profile.image,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...profile.toJson(),
      'accessToken': accessToken,
    };
  }
}
