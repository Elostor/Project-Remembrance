import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}
final class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

final class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

final class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
}

final class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

final class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

final class AuthEventForgotPassword extends AuthEvent {
  final String? email;

  const AuthEventForgotPassword({this.email});
}