import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/models/user_model.dart'; // Added for fromMap/toMap

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  static const String _adminSecret = "MY_SECRET_123";

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final user = _repository.getCurrentUser();
      if (user != null) {
        final profile = await _repository.getUserProfile(user.id);
        if (profile != null) {
          if (profile.status == 'suspended') {
            await _repository.logout();
            emit(Unauthenticated());
          } else {
            emit(Authenticated(profile));
          }
        } else {
          // Keep current state if network fails or use local if profile null?
          // For security, if we can't verify profile and user exists, we might stay Authenticated if hydrated.
          if (state is! Authenticated) {
            emit(Unauthenticated());
          }
        }
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userModel = await _repository.login(event.email, event.password);
        if (userModel != null) {
          if (userModel.status == 'suspended') {
            await _repository.logout();
            emit(AuthError('Your account has been suspended.'));
          } else {
            emit(Authenticated(userModel));
          }
        } else {
          emit(AuthError('Could not fetch user profile.'));
        }
      } catch (e) {
        final errorMessage = e is AuthException ? e.message : e.toString();
        emit(AuthError(errorMessage));
      }
    });

    on<RegisterRequested>((event, emit) async {
      if (event.role == 'superadmin' && event.adminSecretCode != _adminSecret) {
        emit(AuthError('Invalid Admin Secret Code.'));
        return;
      }

      emit(AuthLoading());
      try {
        final userModel = await _repository.register(
          email: event.email,
          password: event.password,
          role: event.role,
        );
        if (userModel != null) {
          emit(Authenticated(userModel));
        } else {
          emit(AuthError('Could not create user profile.'));
        }
      } catch (e) {
        final errorMessage = e is AuthException ? e.message : e.toString();
        emit(AuthError(errorMessage));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _repository.logout();
      emit(Unauthenticated());
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'Authenticated') {
      return Authenticated(UserModel.fromMap(json['user']));
    } else if (json['type'] == 'Unauthenticated') {
      return Unauthenticated();
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {'type': 'Authenticated', 'user': state.user.toMap()};
    } else if (state is Unauthenticated) {
      return {'type': 'Unauthenticated'};
    }
    return null;
  }
}
