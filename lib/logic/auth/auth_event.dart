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
  RegisterRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}
