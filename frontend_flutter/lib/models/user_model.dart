import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final List<String>? roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.roles,
  });

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        profileImage: json["profileImage"],
        createdAt: DateTime.parse(json["createdAt"]),
        roles: json["roles"] == null
            ? null
            : List<String>.from(json["roles"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "profileImage": profileImage,
        "createdAt": createdAt.toIso8601String(),
        "roles": roles == null
            ? null
            : List<dynamic>.from(roles!.map((x) => x)),
      };
}