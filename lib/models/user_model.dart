class User {
  String id;
  String name;
  String email;
  String role;
  String cnic;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.cnic,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role, 'cnic': cnic};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      cnic: json['cnic'] as String,
    );
  }
}
