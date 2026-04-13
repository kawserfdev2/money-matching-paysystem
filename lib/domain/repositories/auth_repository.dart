import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
  User? getCurrentUser();
  Future<UserModel?> getUserProfile(String uid);
}
