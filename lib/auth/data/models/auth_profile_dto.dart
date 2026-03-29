class AuthProfileDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;

  const AuthProfileDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
  });

  factory AuthProfileDto.fromJson(Map<String, dynamic> json) {
    final firstName =
        (json['firstName'] ?? json['first_name'] ?? '') as String;
    final lastName = (json['lastName'] ?? json['last_name'] ?? '') as String;
    final gender = (json['gender'] ?? '') as String;
    final image = (json['image'] ?? '') as String;

    return AuthProfileDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }
}
