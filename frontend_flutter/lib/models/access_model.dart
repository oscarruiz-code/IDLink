import 'dart:convert';

class Access {
  final String id;
  final String name;
  final String type;
  final String? userId;
  final String? targetUserId;
  final DateTime expirationDate;
  final DateTime createdAt;

  Access({
    required this.id,
    required this.name,
    required this.type,
    this.userId,
    this.targetUserId,
    required this.expirationDate,
    required this.createdAt,
  });

  factory Access.fromJson(String str) => Access.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Access.fromMap(Map<String, dynamic> json) => Access(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        userId: json["userId"],
        targetUserId: json["targetUserId"],
        expirationDate: json["expirationDate"] != null
            ? DateTime.parse(json["expirationDate"])
            : DateTime.now().add(const Duration(days: 7)),
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "type": type,
        "userId": userId,
        "targetUserId": targetUserId,
        "expirationDate": expirationDate.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
      };
}