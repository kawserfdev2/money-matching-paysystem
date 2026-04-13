abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;
  final String? adminSecretCode;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.role,
    this.adminSecretCode,
  });
}

class LogoutRequested extends AuthEvent {}
