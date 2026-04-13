import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromSupabase(User user, Map<String, dynamic>? profile) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      role: profile?['role'] ?? 'merchant',
      status: profile?['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'role': role, 'status': status};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'merchant',
      status: map['status'] ?? 'active',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
