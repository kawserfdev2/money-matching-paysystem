import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<UserModel?> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      // Metadata allows us to pass role which can be consumed by the trigger we created earlier
      data: {'role': role},
    );
    if (response.user != null) {
      // Small delay to ensure the database trigger has finished creating the profile
      await Future.delayed(const Duration(seconds: 1));
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final profileResponse = await _supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    return UserModel.fromSupabase(user, profileResponse);
  }
}
