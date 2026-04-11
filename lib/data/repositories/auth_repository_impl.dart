import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<User?> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> register(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
