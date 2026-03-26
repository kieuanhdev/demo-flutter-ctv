import 'auth_profile.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AuthProfile profile;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    AuthProfile? profile,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      profile: profile ?? this.profile,
    );
  }
}
