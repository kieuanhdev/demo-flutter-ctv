import 'auth_profile.dart';

class AuthSession {
  final String accessToken;
  final AuthProfile profile;

  const AuthSession({
    required this.accessToken,
    required this.profile,
  });

  AuthSession copyWith({
    String? accessToken,
    AuthProfile? profile,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      profile: profile ?? this.profile,
    );
  }
}
