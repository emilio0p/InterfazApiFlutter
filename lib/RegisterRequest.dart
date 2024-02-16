class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String description;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'description': description,
    };
  }
}
