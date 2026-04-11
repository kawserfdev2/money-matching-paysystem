import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;

  UserModel({required this.id, required this.email});

  factory UserModel.fromSupabase(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }
}