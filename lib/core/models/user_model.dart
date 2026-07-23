import 'package:mobile_dev_summative/core/models/base_model.dart';

class UserModel extends BaseModel {
  final String name;
  final String email;

  UserModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      name: map["name"],
      email: map["email"],
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "name": name,
      "email": email,
    };
  }
}
