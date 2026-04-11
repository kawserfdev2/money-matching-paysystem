import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AppStarted>((event, emit) {
      final user = _repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user.email!));
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repository.login(event.email, event.password);
        emit(Authenticated(event.email));
      } catch (e) {
        final errorMessage = e is AuthException ? e.message : e.toString();
        emit(AuthError(errorMessage));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repository.register(event.email, event.password);
        emit(Authenticated(event.email));
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
}
