import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final bool isImpersonating;
  final String? impersonatedBrandId;

  Authenticated(
    this.user, {
    this.isImpersonating = false,
    this.impersonatedBrandId,
  });
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
